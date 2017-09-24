//
//  Bike.swift
//  FindMyBike
//
//  Created by James Donohue on 28/08/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import CoreLocation
import os.log

class Bike: NSObject, NSCoding {

    // MARK: Properties
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("bike")
    
    struct PropertyKey {
        static let make = "make"
        static let model = "model"
        static let beaconUUID = "beaconUUID"
        static let beaconMajor = "beaconMajor"
        static let beaconMinor = "beaconMinor"
        static let photo = "photo"
        static let isMissing = "missing"
    }

    // Describes possible validation errors arising during initialisation
    enum ValidationError: Error, CustomStringConvertible {
        case emptyMake
        case emptyModel
        case invalidBeaconUUID
        case invalidBeaconMajor
        case invalidBeaconMinor

        var title: String {
            switch self {
            case .emptyMake:
                return "Empty make"
            case .emptyModel:
                return "Empty model"
            case .invalidBeaconUUID:
                return "Invalid UUID"
            case .invalidBeaconMajor:
                return "Invalid major"
            case .invalidBeaconMinor:
                return "Invalid minor"
            }
        }

        var description: String {
            switch self {
            case .emptyMake:
                return "Please specify a value for the bike make"
            case .emptyModel:
                return "Please specify a value for the bike model"
            case .invalidBeaconUUID:
                return "Beacon UUIDs are 36-character strings separated by dashes, such as 21EECF71-D5C7-4A00-9B90-27C94B5146EA"
            case .invalidBeaconMajor:
                return "The beacon major must be in the range 0-65535"
            case .invalidBeaconMinor:
                return "The beacon minor must be in the range 0-66535"
            }
        }
    }

    enum SerialisationError: Error {
        case missing(String)
    }

    var make: String
    var model: String
    var beaconUUID: UUID
    var beaconMajor: UInt16
    var beaconMinor: UInt16
    
    var photo: UIImage?

    var isMissing = false

    var makeAndModel: String {
        return "\(make) \(model)"
    }
    
    // MARK: Initialisation
    
    init?(make: String, model: String, beaconUUID: UUID, beaconMajor: UInt16, beaconMinor: UInt16, photo: UIImage?) {
        // The make and model must not be empty
        guard !make.isEmpty && !model.isEmpty else {
            return nil
        }

        // Initialise stored properties
        self.make = make
        self.model = model
        self.beaconUUID = beaconUUID
        self.beaconMajor = beaconMajor
        self.beaconMinor = beaconMinor
        
        self.photo = photo
    }

    // Initialise from JSON API representation
    init(json: [String: Any]) throws {
        guard let make = json[PropertyKey.make] as? String else {
            throw SerialisationError.missing(PropertyKey.make)
        }

        guard let model = json[PropertyKey.model] as? String else {
            throw SerialisationError.missing(PropertyKey.model)
        }

        guard let beaconMinor = json[PropertyKey.beaconMinor] as? UInt16 else {
            throw SerialisationError.missing(PropertyKey.beaconMinor)
        }

        guard let isMissing = json[PropertyKey.isMissing] as? Bool else {
            throw SerialisationError.missing(PropertyKey.isMissing)
        }

        self.make = make
        self.model = model
        self.beaconMinor = beaconMinor
        self.isMissing = isMissing

        self.beaconUUID = Constants.applicationUUID
        self.beaconMajor = Constants.applicationMajor
    }

    // MARK: CustomStringConvertible
    
    override var description: String {
        return "\(make) \(model) \(beaconUUID) \(beaconMajor) \(beaconMinor)"
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(make, forKey: PropertyKey.make)
        aCoder.encode(model, forKey: PropertyKey.model)
        aCoder.encode(beaconUUID, forKey: PropertyKey.beaconUUID)
        aCoder.encode(beaconMajor, forKey: PropertyKey.beaconMajor)
        aCoder.encode(beaconMinor, forKey: PropertyKey.beaconMinor)
        aCoder.encode(photo, forKey: PropertyKey.photo)
    }

    // MARK: Core Location

    var region: CLBeaconRegion {
        let identifier = "com.james.MyBeaconRegion"

        return CLBeaconRegion(proximityUUID: beaconUUID, major: beaconMajor, minor: beaconMinor, identifier: identifier)
    }

    // MARK: Convenience initialisers

    required convenience init?(coder aDecoder: NSCoder) {
        // The make and model are required. If we cannot decode them the initializer should fail.
        guard let make = aDecoder.decodeObject(forKey: PropertyKey.make) as? String,
            let model = aDecoder.decodeObject(forKey: PropertyKey.model) as? String,
            let beaconUUID = aDecoder.decodeObject(forKey: PropertyKey.beaconUUID) as? UUID,
            let beaconMajor = aDecoder.decodeObject(forKey: PropertyKey.beaconMajor) as? UInt16,
            let beaconMinor = aDecoder.decodeObject(forKey: PropertyKey.beaconMinor) as? UInt16 else {
            os_log("Unable to decode required Bike object properties", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is optional just use conditional cast
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        // Must call designated initializer.
        self.init(make: make, model: model, beaconUUID: beaconUUID, beaconMajor: beaconMajor, beaconMinor: beaconMinor, photo: photo)
    }

    // Convenience initialiser to handle string inputs (e.g. from a form)
    convenience init(make: String, model: String, beaconUUIDStr: String, beaconMajorStr: String, beaconMinorStr: String, photo: UIImage?) throws {
        guard !make.isEmpty else {
            throw ValidationError.emptyMake
        }
        guard !model.isEmpty else {
            throw ValidationError.emptyModel
        }
        guard let beaconUUID = UUID(uuidString: beaconUUIDStr) else {
            throw ValidationError.invalidBeaconUUID
        }
        guard let beaconMajor = UInt16(beaconMajorStr) else {
            throw ValidationError.invalidBeaconMajor
        }
        guard let beaconMinor = UInt16(beaconMinorStr) else {
            throw ValidationError.invalidBeaconMinor
        }

        // Force designated initialiser not to fail because we have already validated make and model ourselves
        self.init(make: make, model: model, beaconUUID: beaconUUID, beaconMajor: beaconMajor, beaconMinor: beaconMinor, photo: photo)!
    }

    // Convenience initialiser for creating test data easily
    convenience init(make: String, model: String, beaconMinor: UInt16, photo: UIImage?) {
        // NB bypasses make/model validation
        
        self.init(make: make, model: model, beaconUUID: Constants.applicationUUID, beaconMajor: Constants.applicationMajor, beaconMinor: beaconMinor, photo: photo)!
    }

    // Example full bike instance (for testing editing form only)
    override convenience init() {
        let photo = UIImage(named: "examplePhoto")!
        self.init(make: "Suzuki", model: "SV650S", beaconUUID: UUID(uuidString: "21EECF71-D5C7-4A00-9B90-27C94B5146EA")!, beaconMajor: 1, beaconMinor: 1, photo: photo)!
    }
}
