//
//  AlertFactory.swift
//  BeaconRanger
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

// TODO DRY this up
class AlertFactory {
    static func makeNoBeaconSupport() -> UIAlertController {
        let title = "Your device does not support scanning for Bluetooth beacons"
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        return alertController
    }
    
    static func makeRangingNotAuthorisedAlert() -> UIAlertController {
        let title = "Turn on Location Services to allow Bluetooth ranging"
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(okAction)
        
        return alertController
    }
    
    static func makeBluetoothNotAvailableAlert() -> UIAlertController {
        let title = "Turn on Bluetooth to allow ranging"
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
        return alertController
    }

    static func makeMissingBikeAlert() -> UIAlertController {
        let title = "Bike reported as missing"
        let message = "You will receive push notifications about this bike's location if it is detected"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)

        return alertController
    }

    static func apiFailureWarning() -> UIAlertController {
        let title = "There was an error communicating with FindMyBike servers"
        let message = "Please try again later"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)

        return alertController
    }

    static func reportSightingConfirmation(okHandler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let title = "Report bike location to owner?"
        let message = "No personal information will be shared except your map location"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        return alertController
    }

    static func bikeSightedAlert(latitude: Double, longitude: Double, showHandler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let title = "Bike location reported"
        let message = "Another user has detected your bike and reported its location. Tap Show to reveal the location in Maps."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let showAction = UIAlertAction(title: "Show", style: .default, handler: showHandler)
        alertController.addAction(cancelAction)
        alertController.addAction(showAction)

        return alertController
    }
}
