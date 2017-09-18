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
    func didRangeBeacons(minors: [UInt16])
}

class ProximityMonitor: NSObject, CLLocationManagerDelegate {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ProximityMonitor.self))

    let locationManager = CLLocationManager()

    weak var delegate: ProximityMonitorDelegate?

    var deviceSupportsBeacons: Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) && CLLocationManager.isRangingAvailable()
    }

    // MARK: Public interface

    func activate() {
        os_log("activate", log: log, type: .info)

        sendTestData()

        guard deviceSupportsBeacons else {
            os_log("Device does not support beacon monitoring/ranging", log: log, type: .error)
            delegate?.noDeviceBeaconSupport()
            return
        }

        locationManager.delegate = self

        // If authorisation status is notDetermined this will request permission, otherwise is no-op
        locationManager.requestAlwaysAuthorization()
    }

    func sendTestData() {
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.delegate?.didRangeBeacons(minors: [1, 2, 3])
        }
    }

    // MARK: CLLocationManagerDelegate
    // NB these methods should not get called if initialisation exited early due to no beacon suppport

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("didChangeAuthorisationStatus: %@", log: log, type: .info, status.description)

        // NB we may get this event before the application comes back to the foreground
        switch status {
        case .authorizedAlways:
            startMonitoring()
        default:
            // Ignore other statuses
            break
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
        os_log("didRangeBeacons: %lu beacons in region %@", log: log, type: .info, beacons.count, region.identifier)

        guard region == Beacon.region else {
            os_log("Ignoring unexpected region: %@", log: log, type: .error)
            return
        }

        let beaconMinors = beacons.map { UInt16($0.minor) }
        delegate?.didRangeBeacons(minors: beaconMinors)
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        os_log("rangingBeaconsDidFailFor: %@", log: log, type: .error, error.localizedDescription)
    }

    // MARK: Private methods

    private func startMonitoring() {
        os_log("startMonitoring", log: log, type: .error)

        locationManager.startMonitoring(for: Beacon.region)
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

// Use extension to add a human-readable version of authorisation status for debugging
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
