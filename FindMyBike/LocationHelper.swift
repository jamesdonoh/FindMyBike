//
//  LocationHelper.swift
//  FindMyBike
//
//  Created by James Donohue on 30/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import CoreLocation
import os.log

class LocationHelper: NSObject, CLLocationManagerDelegate {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: LocationHelper.self))

    let locationManager = CLLocationManager()

    var handler: ((Double, Double) -> Void)?

    override init() {
        super.init()

        locationManager.delegate = self
    }

    func getLocation(handler: @escaping (Double, Double) -> Void) {
        os_log("getLocation", log: log, type: .debug)

        if self.handler != nil {
            os_log("Location request already in progress, discarding new handler", log: log, type: .error)
        }
        self.handler = handler

        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            os_log("didUpdateLocations, first is %@", log: log, type: .info, location)
            handler?(location.coordinate.latitude, location.coordinate.longitude)
            handler = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("didFailWithError: %@", log: log, type: .info, error.localizedDescription)
        handler = nil
    }
}
