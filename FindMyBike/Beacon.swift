//
//  Beacon.swift
//  FindMyBike
//
//  Created by James Donohue on 17/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import CoreLocation

struct Beacon {
    static let applicationUUID = UUID(uuidString: "21EECF71-D5C7-4A00-9B90-27C94B5146EA")!
    static let applicationMajor = UInt16(1)
    static let regionIdentifier = Bundle.main.bundleIdentifier! + ".BeaconRegion"

    static let region = CLBeaconRegion(proximityUUID: Beacon.applicationUUID, major: Beacon.applicationMajor, identifier: Beacon.regionIdentifier)
}
