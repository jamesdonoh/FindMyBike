//
//  Ranging.swift
//  BeaconRanger
//
//  A singleton class to provide shared BLE ranging services
//
//  Created by James Donohue on 09/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import CoreLocation
import os.log

protocol RangingDelegate: class {
    func rangingNotAvailable()
    func rangingNotAuthorised()
    func bluetoothNotAvailable()
    func didRangeBeacon(proximity: String)
}

enum RangingState {
    case disabled
    case enabled
    case started
    case stopped
}

class Ranging: NSObject, CLLocationManagerDelegate, BluetoothDelegate {
    // MARK: Properties
    
    // Singleton instance
    static let sharedInstance = Ranging()
    
    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: Ranging.self))

    let locationManager = CLLocationManager()

    var region: CLBeaconRegion!

    var state = RangingState.disabled
    
    weak var delegate: RangingDelegate?
    
    // Make default initialiser private to ensure that no other instances can be created
    private override init() {
        super.init()

        locationManager.delegate = self
        BluetoothSupport.sharedInstance.delegate = self
    }

    // MARK: Public interface

    // Called the first time ranging support is actually needed by the application
    func enableRanging(for region: CLBeaconRegion) {
        assert(state == .disabled, "State should be disabled")
        os_log("enableRanging for region %@", log: Ranging.log, type: .debug, region)
        
        if CLLocationManager.isRangingAvailable() {
            self.region = region

            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                os_log("Requesting authorisation", log: Ranging.log, type: .info)
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                os_log("Ranging already enabled", log: Ranging.log, type: .debug)
                state = .enabled
                startRanging()
            case .restricted, .denied:
                reportRangingNotAuthorised()
            }
        } else {
            os_log("Ranging not supported on this device", log: Ranging.log, type: .error)
            delegate?.rangingNotAvailable()
        }
    }
    
    // Called when the application no longer requires ranging
    func disableRanging() {
        os_log("disableRanging", log: Ranging.log, type: .debug)

        guard state != .disabled else {
            os_log("Not disabling ranging because it is not enabled", log: Ranging.log, type: .info)
            return
        }
        
        stopRanging()
        state = .disabled
    }
    
    // Called when app lifecycle events indicate that ranging should stop (e.g. goes to background)
    func stopRanging() {
        os_log("stopRanging", log: Ranging.log, type: .debug)
        
        guard state == .started else {
            os_log("Not stopping ranging because it is not started", log: Ranging.log, type: .info)
            return
        }
        guard region != nil else {
            os_log("Not stopping ranging as no region configured", log: Ranging.log, type: .info)
            return
        }

        locationManager.stopRangingBeacons(in: region)
        state = .stopped
    }
    
    // Called when app lifecycle events indicate that ranging should start (or restart)
    func startRanging() {
        os_log("startRanging", log: Ranging.log, type: .debug)
        
        guard state != .started else {
            os_log("Not starting ranging as it is already started", log: Ranging.log, type: .info)
            return
        }
        guard state != .disabled else {
            os_log("Not starting ranging as it is not yet enabled", log: Ranging.log, type: .info)
            return
        }
        guard region != nil else {
            os_log("Not starting ranging as no region configured", log: Ranging.log, type: .info)
            return
        }
        guard BluetoothSupport.sharedInstance.bluetoothAvailable() else {
            os_log("Not starting ranging as Bluetooth not available", log: Ranging.log, type: .info)
            bluetoothNotAvailable()
            return
        }
        
        locationManager.startRangingBeacons(in: region)
        state = .started
    }

    func rangingAuthorised() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    // NB: "The methods of your delegate object are called from the thread in which you started the corresponding location services."
    // https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        os_log("didRangeBeacons", log: Ranging.log)
        guard beacons.count > 0 else {
            os_log("No beacons ranged", log: Ranging.log, type: .info)
            return
        }
        
        // TODO will this need rethinking when targeting more than one beacon?
        guard region == self.region else {
            os_log("Unexpected region", log: Ranging.log, type: .info)
            return
        }
        
        for beacon in beacons {
            os_log("%@", log: Ranging.log, beacon)
        }
        
        let nearestBeacon = beacons.first!
        
        delegate?.didRangeBeacon(proximity: proximityLabel(nearestBeacon.proximity))
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        // TODO suggest that Bluetooth is disabled (or check directly)
        os_log("rangingBeaconsDidFailFor: %@", log: Ranging.log, type: .error, error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("didChangeAuthorisationStatus: %@", log: Ranging.log, type: .debug, authorizationStatusString(status))
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            os_log("Ranging enabled", log: Ranging.log, type: .debug)
            state = .enabled
            startRanging()
        case .notDetermined:
            // Authorisation should already have been requested at this point, so do nothing further
            break
        case .restricted, .denied:
            disableRanging()
            reportRangingNotAuthorised()
        }
    }
    
    // MARK: BluetoothDelegate
    
    func bluetoothAvailable() {
        os_log("bluetoothAvailable", log: Ranging.log, type: .debug)
        
        startRanging()
    }
    
    func bluetoothNotAvailable() {
        os_log("bluetoothNotAvailable", log: Ranging.log, type: .debug)
        
        stopRanging()

        // Allow our delegate to notify the user that Bluetooth is not available
        delegate?.bluetoothNotAvailable()
    }
    
    // MARK: Private methods
    
    private func reportRangingNotAuthorised() {
        os_log("Use of ranging was not authorized", log: Ranging.log, type: .error)
        delegate?.rangingNotAuthorised()
    }
    
    // TODO replace with an extension?
    private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
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

    func proximityLabel(_ proximity: CLProximity) -> String {
        switch proximity {
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
