//
//  ProximityMonitor.swift
//  FindMyBike
//
//  Created by James Donohue on 17/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import CoreLocation
import os.log

protocol ProximityMonitorDelegate: class {
    func noDeviceBeaconSupport()
    func didRangeBeacons(beacons: [(minor: UInt16, proximity: String)])
    func monitoringFailure()
}

class ProximityMonitor: NSObject, CLLocationManagerDelegate, BluetoothDelegate {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ProximityMonitor.self))

    let locationManager = CLLocationManager()
    let bluetoothSupport = BluetoothSupport()

    weak var delegate: ProximityMonitorDelegate?

    var deviceSupportsBeacons: Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) && CLLocationManager.isRangingAvailable()
    }

    // MARK: Initialisation
    override init() {
        os_log("init", log: log, type: .debug)
        super.init()

        locationManager.delegate = self
        bluetoothSupport.delegate = self
    }

    // MARK: Public interface

    func activate() {
        os_log("activate", log: log, type: .debug)

        guard deviceSupportsBeacons else {
            os_log("Device does not support beacon monitoring/ranging", log: log, type: .error)
            delegate?.noDeviceBeaconSupport()
            return
        }

        // If authorisation status is notDetermined this will request permission, otherwise is no-op
        locationManager.requestAlwaysAuthorization()

        // We may be already authorised and returning to the foreground
        if isAuthorised {
            checkRegionState()
        }
    }

    func deactivate() {
        os_log("deactivate", log: log, type: .debug)

        // Before going to background check region state - avoids ranging in background if not in region
        if isAuthorised {
            checkRegionState()
        }
    }

    // MARK: CLLocationManagerDelegate
    // NB methods should not get called if initialisation exited early due to no beacon suppport

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("didChangeAuthorisationStatus: %@", log: log, type: .info, status.description)

        // NB we may get this event before application comes back to the foreground
        if isAuthorised {
            startMonitoring()
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        os_log("didEnterRegion: %@", log: log, type: .info, region.identifier)

        startRanging()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        os_log("didExitRegion: %@", log: log, type: .info, region.identifier)

        stopRanging()
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        os_log("didDetermineState: %@", log: log, type: .info, state.description)

        if state == .inside {
            startRanging()
        } else if state == .outside {
            stopRanging()
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        os_log("monitoringDidFailFor: %@", log: log, type: .error, error.localizedDescription)
        delegate?.monitoringFailure()
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        os_log("didRangeBeacons: %lu beacons", log: log, type: .info, beacons.count)

        guard region.identifier == Beacon.region.identifier else {
            os_log("Ignoring unexpected region: %@", log: log, type: .error)
            return
        }

        // To hide implementation, pass a tuple of beacon minor and proximity description to the delegate
        let beaconsWithProxmity = beacons.map { (UInt16($0.minor), $0.proximity.description) }
        delegate?.didRangeBeacons(beacons: beaconsWithProxmity)
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        os_log("rangingBeaconsDidFailFor: %@", log: log, type: .error, error.localizedDescription)
        delegate?.monitoringFailure()
    }

    // MARK: BluetoothDelagate

    func bluetoothAvailable() {
        os_log("bluetoothAvailable", log: log, type: .debug)
    }

    func bluetoothNotAvailable() {
        os_log("bluetoothNotAvailable", log: log, type: .debug)
    }

    // MARK: Private properties

    private var isAuthorised: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    private var isMonitoring: Bool {
        return locationManager.monitoredRegions.map { $0.identifier }.contains(Beacon.region.identifier)
    }

    private var isRanging: Bool {
        return locationManager.rangedRegions.map { $0.identifier }.contains(Beacon.region.identifier)
    }

    // MARK: Private methods

    private func startMonitoring() {
        if !isMonitoring {
            os_log("startMonitoring", log: log, type: .error)
            locationManager.startMonitoring(for: Beacon.region)
        }
    }

    private func startRanging() {
        if !isRanging {
            os_log("startRanging", log: log, type: .debug)
            locationManager.startRangingBeacons(in: Beacon.region)
        }
    }

    private func stopRanging() {
        if isRanging {
            os_log("stopRanging", log: log, type: .debug)
            locationManager.stopRangingBeacons(in: Beacon.region)
        }
    }

    private func checkRegionState() {
        locationManager.requestState(for: Beacon.region)
    }
}
