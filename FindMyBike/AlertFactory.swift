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

    static func apiFailureWarning() -> UIAlertController {
        let title = "There was an error communicating with FindMyBike servers"
        let message = "Please try again later"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)

        return alertController
    }
}
