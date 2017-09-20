//
//  CLExtensions.swift
//  FindMyBike
//
//  Use Swift extensions to add a human-readable versions of status/proxmity/state info
//
//  Created by James Donohue on 20/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import CoreLocation


extension CLAuthorizationStatus {
    var description: String {
        switch self {
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
}

extension CLProximity {
    var description: String {
        switch self {
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

extension CLRegionState {
    var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .inside:
            return "inside"
        case .outside:
            return "outside"
        }
    }
}
