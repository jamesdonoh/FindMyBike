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

    // MARK: iBeacon constants

    static let applicationUUID = UUID(uuidString: "21EECF71-D5C7-4A00-9B90-27C94B5146EA")!
    static let applicationMajor = UInt16(1)
    static let regionIdentifier = Bundle.main.bundleIdentifier!

    static let region = CLBeaconRegion(proximityUUID: Constants.applicationUUID, major: Constants.applicationMajor, identifier: Constants.regionIdentifier)

    // MARK: API constants

    static let apiBaseUrl = "https://murmuring-brushlands-57895.herokuapp.com"
    static let apiKey = "1ed61ce217fbf80"

    // Use closure to customise default value
    static let apiBaseUrlComponents: URLComponents = {
        var components = URLComponents(string: Constants.apiBaseUrl)!
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        return components
    }()
}
