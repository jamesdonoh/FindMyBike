//
//  BikeRegistry.swift
//  FindMyBike
//
//  Created by James Donohue on 17/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

class BikeRegistry {

    // MARK: Properties

    static let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let myBikeArchiveUrl = documentDirectory.appendingPathComponent("mybike")

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: BikeRegistry.self))

    let api = BikeRegistryAPI()

    var myBike: Bike? = BikeRegistry.loadMyBike() {
        // Property observers not called during initialisation
        didSet {
            api.createOrUpdate(registry: self, bike: myBike)
        }
    }

    static var r1 = Bike(make: "Yamaha", model: "YZF-R1", colour: .blue, beaconMinor: 3, isMissing: false, photo: UIImage(named: "bike2"), id: nil)

    var bikes = [UInt16: Bike]()

    // MARK: Initialisation

    init() {
        os_log("init; myBike is %@", log: log, type: .debug, myBike?.description ?? "nil")

        #if IOS_SIMULATOR
            os_log("documentDirectory: %@", log: log, type: .debug, BikeRegistry.documentDirectory.path)
        #endif
    }

    // MARK: Public interface

    // TODO make these more elegant using map/filter?
    func findMyBikeProximity(beacons: [(minor: UInt16, proximity: String)]) -> String? {
        for beacon in beacons {
            if beacon.minor == myBike?.beaconMinor {
                return beacon.proximity
            }
        }

        return nil
    }

    func findMissingBikes(beacons: [(minor: UInt16, proximity: String)]) -> [(bike: Bike, proximity: String)] {
        // TODO make this more elegant using map/filter?
        var missing = [(bike: Bike, proximity: String)]()

        for beacon in beacons {
            if let bike = bikes[beacon.minor], bike.isMissing {
                missing.append(bike: bike, proximity: beacon.proximity)
            }
        }

        // TODO make Bike implement Comparable protocol to preseve inherent order instead
        // https://developer.apple.com/documentation/swift/comparable
        return missing.sorted(by: { $0.bike.makeAndModel > $1.bike.makeAndModel })
    }

    func loadBikes() {
        //TODO reactor avoid API class having to know about registry  
        api.getBikes(registry: self)
    }

    // MARK: Local persistence using keyed archiver (subclass of NSCoder)

    func saveMyBike() {
        saveToFile(bike: myBike, file: BikeRegistry.myBikeArchiveUrl)
    }

    private func saveToFile(bike: Bike?, file: URL) {
        if let bike = bike {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bike, toFile: file.path)
            if isSuccessfulSave {
                os_log("Bike data successfully saved to file: %@", log: log, type: .debug, bike.description)
            } else {
                os_log("Error saving bike to file", log: log, type: .error)
            }
        }
    }

    private static func loadMyBike() -> Bike? {
        return BikeRegistry.loadFromFile(file: BikeRegistry.myBikeArchiveUrl)
    }

    private static func loadFromFile(file: URL) -> Bike? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: file.path) as? Bike
    }
}
