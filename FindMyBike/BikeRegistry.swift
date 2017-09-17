//
//  BikeRegistry.swift
//  FindMyBike
//
//  Created by James Donohue on 17/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

class BikeRegistry {

    var missingBikes = [
        Bike(make: "Honda", model: "CBR1000RR", beaconMinor: 1, photo: UIImage(named: "bike1")),
        Bike(make: "Yamaha", model: "YZF-R1", beaconMinor: 2, photo: UIImage(named: "bike2")),
        Bike(make: "Triumph", model: "Speed Triple R", beaconMinor: 3, photo: UIImage(named: "bike3")),
    ]
}
