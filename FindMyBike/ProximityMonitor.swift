//
//  ProximityMonitor.swift
//  FindMyBike
//
//  Created by James Donohue on 17/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import CoreLocation
import os.log

class ProximityMonitor: NSObject, CLLocationManagerDelegate {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ProximityMonitor.self))

    let locationManager = CLLocationManager()

    // MARK: Initialisation

    override init() {
        os_log("init", log: log, type: .debug)
        super.init()

        locationManager.delegate = self
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("didFailWithError: %@", log: log, type: .error, error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        os_log("rangingBeaconsDidFailFor: %@", log: log, type: .error, error.localizedDescription)
    }
}
