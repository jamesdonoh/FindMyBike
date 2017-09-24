//
//  BikeRegistry.swift
//  FindMyBike
//
//  Created by James Donohue on 17/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

protocol BikeRegistryDelegate: class {
    func apiRequestFailed()
}

class BikeRegistry {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: BikeRegistry.self))

    // Use shared URLSession for API requests (could be replaced with a separate instance if 
    // delegate callbacks are required)
    let session = URLSession.shared

    var myBike: Bike?

    weak var delegate: BikeRegistryDelegate?

    static var r1 = Bike(make: "Yamaha", model: "YZF-R1", beaconMinor: 3, photo: UIImage(named: "bike2"))

    var bikes = [UInt16: Bike]()

    var missingBikes: [UInt16: Bike] {
        return bikes
    }

    // MARK: Public methods

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
            if let bike = missingBikes[beacon.minor] {
                missing.append(bike: bike, proximity: beacon.proximity)
            }
        }

        // TODO make Bike implement Comparable protocol to preseve inherent order instead
        // https://developer.apple.com/documentation/swift/comparable
        return missing.sorted(by: { $0.bike.makeAndModel > $1.bike.makeAndModel })
    }

    func getBikeData() {
        os_log("getBikeData", log: log, type: .debug)

        session.dataTask(with: getAllBikesRequest()) { data, response, error in
            if let error = error {
                os_log("Request error: %@", log: self.log, type: .error, error.localizedDescription)
                self.delegate?.apiRequestFailed()
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, httpResponse.mimeType == "application/json" else {
                os_log("Unexpected response: %@", log: self.log, type: .error, response.debugDescription)
                self.delegate?.apiRequestFailed()
                return
            }

            do {
                if let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    for bikeJson in json {
                        let bike = try Bike(json: bikeJson)
                        os_log("Adding bike: %@", log: self.log, type: .info, bike.makeAndModel)
                        self.bikes.updateValue(bike, forKey: bike.beaconMinor)
                    }
                } else {
                    os_log("Totally unacceptable response", log: self.log, type: .error)
                    self.delegate?.apiRequestFailed()
                }
            } catch {
                os_log("Error deserialising JSON: %@", log: self.log, type: .error)
                self.delegate?.apiRequestFailed()
            }
        }.resume()
    }

    // MARK: Private methods

    private func getAllBikesRequest() -> URLRequest {
        var urlComponents = Constants.apiBaseUrlComponents
        urlComponents.path = "/bikes"

        return URLRequest(url: urlComponents.url!)
    }
}
