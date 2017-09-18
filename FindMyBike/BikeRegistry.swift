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

    private var exampleBikes = [
        Bike(make: "Honda", model: "CBR1000RR", beaconMinor: 1, photo: UIImage(named: "bike1")),
        Bike(make: "Yamaha", model: "YZF-R1", beaconMinor: 2, photo: UIImage(named: "bike2")),
        Bike(make: "Triumph", model: "Speed Triple R", beaconMinor: 3, photo: UIImage(named: "bike3")),
    ]

    // MARK: Public methods

    // This could be replaced with a more efficient implementation using a [UInt16: Bike]
    // Dictionary and the new 'filter' method
    func lookup(by minors: [UInt16]) -> [Bike] {
        return exampleBikes.filter { minors.contains($0.beaconMinor) }
    }
}
