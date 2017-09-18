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
}

class ProximityMonitor: NSObject, CLLocationManagerDelegate {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ProximityMonitor.self))

    let locationManager = CLLocationManager()

    weak var delegate: ProximityMonitorDelegate?

    var deviceSupportsBeacons: Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) && CLLocationManager.isRangingAvailable()
    }

    // MARK: Initialisation
    override init() {
        os_log("init", log: log, type: .debug)
        super.init()

        locationManager.delegate = self
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

        // If already authorised and we are returning to the foreground, resume ranging
        if isAuthorised {
            startRanging()
        }
    }

    func deactivate() {
        os_log("deactivate", log: log, type: .debug)

        // Note: ranging must be stopped but monitoring can continue in the background
        stopRanging()
    }

//    func sendTestData() {
//        let deadlineTime = DispatchTime.now() + .seconds(3)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//            self.delegate?.didRangeBeacons(minors: [1, 2, 3])
//        }
//    }

    // MARK: CLLocationManagerDelegate
    // NB these methods should not get called if initialisation exited early due to no beacon suppport

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("didChangeAuthorisationStatus: %@", log: log, type: .info, status.description)

        // NB  may get this event before application comes back to the foreground so do not range yet
        if isAuthorised {
            startMonitoring()
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        os_log("didEnterRegion: %@", log: log, type: .info, region.identifier)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        os_log("didExitRegion: %@", log: log, type: .info, region.identifier)
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        os_log("monitoringDidFailFor: %@", log: log, type: .error, error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        os_log("didRangeBeacons: %lu beacons", log: log, type: .info, beacons.count)

        guard region == Beacon.region else {
            os_log("Ignoring unexpected region: %@", log: log, type: .error)
            return
        }

        // To hide implementation, pass a tuple of beacon minor and proximity description to the delegate
        let beaconsWithProxmity = beacons.map { (UInt16($0.minor), $0.proximity.description) }
        delegate?.didRangeBeacons(beacons: beaconsWithProxmity)
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        os_log("rangingBeaconsDidFailFor: %@", log: log, type: .error, error.localizedDescription)
    }

    // MARK: Private properties

    private var isAuthorised: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    private var isMonitoring: Bool {
        return locationManager.monitoredRegions.contains(Beacon.region)
    }

    private var isRanging: Bool {
        return locationManager.rangedRegions.contains(Beacon.region)
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

    // Helper method to debug issues with location/ranging availability
    private func logAvailabilityInfo() {
        // Notes on user flow
        //
        // First run, all location services turned off
        // - Shows "Turn On Location Services" prompt automatically
        // - didChangeAuthorisationStatus: denied
        // If user enables location services changes to:
        // - didChangeAuthorisationStatus: notDetermined
        // So need to request again when app comes back to foreground!
        //
        //

        // Returns false if the user has disabled location services globally
        // However if this is the case the system will automatically prompt the user to turn it on, so we can ignore
        os_log("locationServicesEnabled = %@", log: log, type: .debug, CLLocationManager.locationServicesEnabled() ? "true" : "false")

        // The following two flags describe device capabilities - e.g. they may true on a real device
        // even if Bluetooth is currently switched. They always return false on an iPhone simulator
        os_log("isMonitoringAvailable(Beacon) = %@", log: log, type: .debug, CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) ? "true" : "false")
        os_log("isRangingAvailable = %@", log: log, type: .debug, CLLocationManager.isRangingAvailable() ? "true" : "false")
    }
}

// Use extension to add a human-readable versions of status/proxmity info

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        case .authorizedAlways:
            return "authorizedAlways"
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        }
    }
}

extension CLProximity {
    var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
        }
    }
}
