//
//  AlertFactory.swift
//  BeaconRanger
//
//  Helper class to contain common logic for creating UIAlert classes
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import MapKit

class AlertFactory {
    static func generic(title: String, message: String? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        return alertController
    }

    static func noBeaconSupport() -> UIAlertController {
        return AlertFactory.generic(title: "Your device does not support scanning for Bluetooth beacons")
    }
    
    static func rangingNotAuthorised() -> UIAlertController {
        let title = "Turn on Location Services to allow Bluetooth ranging"
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(settingsAction)
        alertController.addAction(okAction)
        
        return alertController
    }
    
    static func bluetoothNotAvailable() -> UIAlertController {
        return AlertFactory.generic(title: "Turn on Bluetooth to allow ranging")
    }

    static func confirmBikeMissing() -> UIAlertController {
        let title = "Bike reported as missing"
        let message = "You will receive push notifications about this bike's location if it is detected"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        return alertController
    }

    static func apiFailureWarning() -> UIAlertController {
        return AlertFactory.generic(title: "There was an error communicating with FindMyBike servers", message: "Please try again later")
    }

    static func confirmReportSighting(okHandler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let title = "Report bike location to owner?"
        let message = "No personal information will be shared except your map location"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        return alertController
    }

    static func bikeSighted(latitude: Double, longitude: Double, description: String) -> UIAlertController {
        let title = "Bike location reported"
        let message = "Another user has detected your bike and reported its location. Tap Show to reveal the location in Maps."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let showAction = UIAlertAction(title: "Show", style: .default) { _ in
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = description
            mapItem.openInMaps()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(showAction)

        return alertController
    }
}
