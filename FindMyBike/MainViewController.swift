//
//  MainViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 16/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

class MainViewController: AppEventViewController, ProximityMonitorDelegate, RangingTableDelegate, BikeRegistryAPIDelegate {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: MainViewController.self))

    let bikeRegistry = BikeRegistry()
    let proximityMonitor = ProximityMonitor()
    let notifications = Notifications()

    var haveAlertedNoBeaconSupport = false

    var haveNotifiedMissingBikesInRange = false

    @IBOutlet weak var statusMessageLabel: UILabel!
    
    weak var rangingTableViewController: RangingTableViewController?

    // MARK: UIViewController

    override func viewDidLoad() {
        os_log("viewDidLoad", log: log, type: .debug)
        super.viewDidLoad()

        //statusMessageLabel.text = "Scanning..."
        statusMessageLabel.text = nil

        proximityMonitor.delegate = self
        proximityMonitor.activate()

        bikeRegistry.api.delegate = self
        bikeRegistry.loadBikes()

        #if IOS_SIMULATOR
            // Trigger synthetic range event to allow generation of screenshots on simulator
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                let fakeBeacons = Array(self.bikeRegistry.bikes.keys).map { (minor: $0, proximity: "Near")}
                self.didRangeBeacons(beacons: fakeBeacons)
            }
        #endif
    }

    // Store references to  child view controllers when embed segue occurs
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let rangingTableViewController = segue.destination as? RangingTableViewController {
            rangingTableViewController.myBike = bikeRegistry.myBike
            rangingTableViewController.delegate = self
            self.rangingTableViewController = rangingTableViewController
        }
    }

    // MARK: AppEventViewController

    override func applicationDidBecomeActive(_ notification: NSNotification!) {
        os_log("applicationDidBecomeActive", log: log, type: .debug)

        // May be coming back from Settings app, so another chance to enable location services
        proximityMonitor.activate()
    }

    override func applicationWillResignActive(_ notification: NSNotification!) {
        os_log("applicationWillResignActive", log: log, type: .debug)

        // Allow ProximityMonitor to take action before going to background
        proximityMonitor.deactivate()

        haveNotifiedMissingBikesInRange = false
    }

    // MARK: ProximityMonitorDelegate

    func noDeviceBeaconSupport() {
        // Avoid repeating alert every time app comes into foreground
        if !haveAlertedNoBeaconSupport {
            tryToPresent(AlertFactory.noBeaconSupport())
            haveAlertedNoBeaconSupport = true
        }
    }

    func didRangeBeacons(beacons: [(minor: UInt16, proximity: String)]) {
        let missingBikes = bikeRegistry.findMissingBikes(beacons: beacons)

        switch UIApplication.shared.applicationState {
        case .active, .inactive:
            let myBikeProximity = bikeRegistry.findMyBikeProximity(beacons: beacons)

            rangingTableViewController?.myBikeProximity = myBikeProximity
            rangingTableViewController?.missingBikes = missingBikes
        case .background:
            if missingBikes.count > 0 && !haveNotifiedMissingBikesInRange {
                notifications.send(message: "Missing bikes detected nearby")

                // Avoid sending repeated notifications
                haveNotifiedMissingBikesInRange = true
            }
        }
    }

    func monitoringFailure() {
        // Something bad happened while monitoring, so any region data may be invalid
        rangingTableViewController?.myBikeProximity = nil
        rangingTableViewController?.missingBikes = []
    }

    // MARK: RangingTableDelegate

    func myBikeUpdated(newBike: Bike?) {
        bikeRegistry.myBike = newBike
    }

    func reportSighting(bike: Bike) {
        tryToPresent(AlertFactory.confirmReportSighting { _ in
            self.bikeRegistry.api.reportSighting(bike: bike)
        })
    }

    // MARK: BikeRegistryAPIDelegate

    func requestFailed() {
        tryToPresent(AlertFactory.apiFailureWarning())
    }

    // MARK: Private methods

    func tryToPresent(_ alert: UIAlertController) {
        if let currentlyPresented = parent?.presentedViewController as? UIAlertController {
            os_log("Refusing to present alert because already presenting: %@", log: log, type: .error, currentlyPresented.title!)
        } else {
            parent?.present(alert, animated: true)
        }
    }
}
