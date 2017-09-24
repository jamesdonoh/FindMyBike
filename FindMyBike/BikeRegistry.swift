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

//    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
//    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: BikeRegistry.self))

    // Use shared URLSession for API requests (could be replaced with a separate instance if 
    // delegate callbacks are required)
    let session = URLSession.shared

    var myBike: Bike? {
        didSet {
            createOrUpdate(bike: myBike)
        }
    }

    weak var delegate: BikeRegistryDelegate?

    static var r1 = Bike(make: "Yamaha", model: "YZF-R1", beaconMinor: 3, photo: UIImage(named: "bike2"), id: nil)

    var bikes = [UInt16: Bike]()

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
            if let bike = bikes[beacon.minor], bike.isMissing {
                missing.append(bike: bike, proximity: beacon.proximity)
            }
        }

        // TODO make Bike implement Comparable protocol to preseve inherent order instead
        // https://developer.apple.com/documentation/swift/comparable
        return missing.sorted(by: { $0.bike.makeAndModel > $1.bike.makeAndModel })
    }

    func getBikeData() {
        os_log("getBikeData", log: log, type: .debug)

        let request = allBikesRequest()
        jsonApiRequest(request: request) { parsedJson in
            guard let parsedJsonArray = parsedJson as? [[String: Any]] else {
                os_log("JSON does not contain a single object", log: self.log, type: .error)
                self.delegate?.apiRequestFailed()
                return
            }

            // Create bike objects from API response
            for bikeJson in parsedJsonArray {
                do {
                    let bike = try Bike(json: bikeJson)
                    os_log("Adding bike: %@", log: self.log, type: .info, bike.makeAndModel)
                    self.bikes.updateValue(bike, forKey: bike.beaconMinor)
                } catch {
                    os_log("Skipping invalid/incomplete JSON: %@", log: self.log, type: .error, bikeJson)
                    continue
                }
            }
        }
    }

    // MARK: Private methods

    private func createOrUpdate(bike: Bike?) {
        os_log("createOrUpdate: %@", log: log, type: .debug, bike?.description ?? "(no bike)")

        guard let bike = bike, let bikeJson = bike.asJson else {
            os_log("Missing or invalid bike data, unable to update", log: log, type: .error)
            return
        }

        os_log("Sending data: %@", log: log, type: .debug, String(data: bikeJson, encoding: .utf8)!)

        let request = createOrUpdateRequest(bike: bike)
        jsonApiRequest(request: request) { parsedJson in
            guard let parsedJsonObject = parsedJson as? [String: Any] else {
                os_log("JSON does not contain a single object", log: self.log, type: .error)
                self.delegate?.apiRequestFailed()
                return
            }

            //os_log("Got response: %@", log: self.log, type: .debug, parsedJsonObject)

            // Store ID from API response in bike instance
            if let newId = parsedJsonObject[Bike.PropertyKey.id] as? String {
                bike.id = newId
            }
        }
    }

    // Helper function for making JSON API requests
    private func jsonApiRequest(request: URLRequest, completion: @escaping ((Any) -> Void)) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                os_log("Request error: %@", log: self.log, type: .error, error.localizedDescription)
                self.delegate?.apiRequestFailed()
                return
            }
            let data = data!

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, httpResponse.mimeType == "application/json" else {
                os_log("Unexpected response: %@", log: self.log, type: .error, response.debugDescription)
                self.delegate?.apiRequestFailed()
                return
            }

            do {
                let parsedJson = try JSONSerialization.jsonObject(with: data)
                completion(parsedJson)
            } catch {
                os_log("Error deserialising JSON: %@", log: self.log, type: .error)
                self.delegate?.apiRequestFailed()
                return
            }
        }.resume()
    }

    // Makes a GET request that returns a list of all bikes
    private func allBikesRequest() -> URLRequest {
        return baseRequest()
    }

    // Uses POST to updates an existing bike (if the 'id' property is set) or create a new one
    private func createOrUpdateRequest(bike: Bike) -> URLRequest {
        var request = baseRequest()

        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bike.asJson!

        return request
    }

    private func baseRequest() -> URLRequest {
        var request = URLRequest(url: baseUrl())
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

        return request
    }

    private func baseUrl() -> URL {
        var components = URLComponents(string: Constants.apiBaseUrl)!
        components.queryItems = [URLQueryItem(name: "key", value: Constants.apiKey)]
        components.path = "/bikes"

        return components.url!
    }
}
