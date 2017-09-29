//
//  BikeRegistryAPI.swift
//  FindMyBike
//
//  Created by James Donohue on 25/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import Foundation
import os.log

protocol BikeRegistryAPIDelegate: class {
    func requestFailed()
}

class BikeRegistryAPI {

    // MARK: Properties

    // Use shared URLSession for API requests (could be replaced with a separate instance if
    // delegate callbacks are required)
    let session = URLSession.shared

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: BikeRegistry.self))

    weak var delegate: BikeRegistryAPIDelegate?

    // MARK: Public interface

    func getBikes(registry: BikeRegistry) {
        os_log("apiGetBikes", log: log, type: .debug)

        let request = allBikesRequest()
        jsonApiRequest(request: request) { parsedJson in
            guard let parsedJsonArray = parsedJson as? [[String: Any]] else {
                os_log("JSON does not contain a single object", log: self.log, type: .error)
                self.delegate?.requestFailed()
                return
            }

            // Create bike objects from API response
            for bikeJson in parsedJsonArray {
                do {
                    let bike = try Bike(json: bikeJson)
                    os_log("Adding bike: %@", log: self.log, type: .info, bike.description)
                    registry.bikes.updateValue(bike, forKey: bike.beaconMinor)
                } catch {
                    os_log("Skipping invalid/incomplete JSON: %@", log: self.log, type: .error, bikeJson)
                    continue
                }
            }

            os_log("getBikes complete: registry now contains %lu bikes", log: self.log, type: .debug, registry.bikes.count)
        }
    }

    func createOrUpdate(registry: BikeRegistry, bike: Bike?) {
        os_log("apiCreateOrUpdate: %@", log: log, type: .debug, bike?.description ?? "(no bike)")

        guard let bike = bike, let bikeJson = bike.asJson else {
            os_log("Missing or invalid bike data, unable to update", log: log, type: .error)
            return
        }

        os_log("Sending data: %@", log: log, type: .debug, String(data: bikeJson, encoding: .utf8)!)

        let request = createOrUpdateRequest(bike: bike)
        jsonApiRequest(request: request) { parsedJson in
            guard let parsedJsonObject = parsedJson as? [String: Any] else {
                os_log("JSON does not contain a single object", log: self.log, type: .error)
                self.delegate?.requestFailed()
                return
            }

            //os_log("Got response: %@", log: self.log, type: .debug, parsedJsonObject)

            // Store ID from API response in bike instance
            if let newId = parsedJsonObject[Bike.PropertyKey.id] as? String {
                bike.id = newId
                registry.saveMyBike()
            }
        }
    }

    // MARK: Private methods

    // Helper function for making JSON API requests
    private func jsonApiRequest(request: URLRequest, completion: @escaping ((Any) -> Void)) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                os_log("Request error: %@", log: self.log, type: .error, error.localizedDescription)
                self.delegate?.requestFailed()
                return
            }
            let data = data!

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, httpResponse.mimeType == "application/json" else {
                os_log("Unexpected response: %@", log: self.log, type: .error, response.debugDescription)
                self.delegate?.requestFailed()
                return
            }

            do {
                let parsedJson = try JSONSerialization.jsonObject(with: data)
                completion(parsedJson)
            } catch {
                os_log("Error deserialising JSON: %@", log: self.log, type: .error)
                self.delegate?.requestFailed()
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
