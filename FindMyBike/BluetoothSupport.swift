//
//  BluetoothSupport.swift
//  BeaconRanger
//
//  Utility methods for working with Bluetooth
//
//  Implemented using singleton pattern to allow it to conform to CBCentralManagerDelegate
//  protocol
//
//  Created by James Donohue on 09/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import CoreBluetooth
import os.log

protocol BluetoothDelegate {
    func bluetoothAvailable()
    func bluetoothNotAvailable()
}

class BluetoothSupport: NSObject, CBCentralManagerDelegate {
    
    // MARK: Properties
    
    // Singleton instance
    static let sharedInstance = BluetoothSupport()

    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: BluetoothSupport.self))
    
    var btManager: CBCentralManager!
    
    var delegate: BluetoothDelegate?
    
    // Make default initialiser private to ensure that no other instances can be created
    override init() {
        super.init()
        btManager = CBCentralManager(delegate: self, queue: nil)
        
        os_log("Initial manager state: %@", log: BluetoothSupport.log, type: .info, stateString())
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        os_log("centralManagerDidUpdateState: %@", log: BluetoothSupport.log, type: .info, stateString())
        
        if bluetoothAvailable() {
            delegate?.bluetoothAvailable()
        } else {
            delegate?.bluetoothNotAvailable()
        }
    }
 
    func bluetoothAvailable() -> Bool {
        return btManager.state == .poweredOn
    }
    
    // MARK: Private methods
    
    private func stateString() -> String {
        switch(btManager.state) {
        case .resetting:
            return "resetting"
        case .poweredOn:
            return "powered on";
        case .poweredOff:
            return "powered off";
        case .unknown:
            return "unknown";
        case .unsupported:
            return "unsupported";
        case .unauthorized:
            return "unauthorized";
        }
    }
}
