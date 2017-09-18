//
//  BikeRegistry.swift
//  FindMyBike
//
//  Created by James Donohue on 17/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

class BikeRegistry {

    // MARK: Properties

    var missingBikes: [UInt16: Bike] = [
        1: Bike(make: "Honda", model: "CBR1000RR", beaconMinor: 1, photo: UIImage(named: "bike1")),
        2: Bike(make: "Yamaha", model: "YZF-R1", beaconMinor: 2, photo: UIImage(named: "bike2")),
        3: Bike(make: "Triumph", model: "Speed Triple R", beaconMinor: 3, photo: UIImage(named: "bike3"))
    ]

    // MARK: Public methods

    func findMissing(beacons: [(minor: UInt16, proximity: String)]) -> [(bike: Bike, proximity: String)] {
        // TODO make this more elegant using map/filter?
        var missing = [(bike: Bike, proximity: String)]()

        for beacon in beacons {
            if let bike = missingBikes[beacon.minor] {
                missing.append(bike: bike, proximity: beacon.proximity)
            }
        }

        return missing
    }
}
