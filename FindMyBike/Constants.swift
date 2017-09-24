//
//  Constants.swift
//  FindMyBike
//
//  Constants shared across application which may only be changed at compile time.
//
//  Created by James Donohue on 17/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import CoreLocation

struct Constants {
    static let applicationUUID = UUID(uuidString: "21EECF71-D5C7-4A00-9B90-27C94B5146EA")!
    static let applicationMajor = UInt16(1)
    static let regionIdentifier = Bundle.main.bundleIdentifier!

    static let region = CLBeaconRegion(proximityUUID: Constants.applicationUUID, major: Constants.applicationMajor, identifier: Constants.regionIdentifier)
}
