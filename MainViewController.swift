//
//  MainViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 16/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

class MainViewController: AppEventViewController, ProximityMonitorDelegate {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: MainViewController.self))

    let bikeRegistry = BikeRegistry()
    let proximityMonitor = ProximityMonitor()

    var haveAlertedNoBeaconSupport = false

    weak var statusViewController: StatusViewController?
    weak var rangingTableViewController: RangingTableViewController?

    // MARK: UIViewController

    override func viewDidLoad() {
        os_log("viewDidLoad", log: log, type: .debug)
        super.viewDidLoad()

        proximityMonitor.delegate = self
        proximityMonitor.activate()
    }

    // Store references to  child view controllers when embed segue occurs
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statusViewController = segue.destination as? StatusViewController {
            self.statusViewController = statusViewController
        } else if let rangingTableViewController = segue.destination as? RangingTableViewController {
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

        // Notify ProximityMonitor to stop foreground activities such as ranging, as per Apple advice
        proximityMonitor.deactivate()
    }

    // MARK: ProximityMonitorDelegate

    func noDeviceBeaconSupport() {
        // Avoid repeating alert every time app comes into foreground
        if !haveAlertedNoBeaconSupport {
            tryToPresent(AlertFactory.makeNoBeaconSupport())
            haveAlertedNoBeaconSupport = true
        }
    }

    func didRangeBeacons(beacons: [(minor: UInt16, proximity: String)]) {
        let missingItems = bikeRegistry.findMissing(beacons: beacons)

        rangingTableViewController?.missingItems = missingItems
    }

    // MARK: Private methods

    func tryToPresent(_ alert: UIAlertController) {
        if let currentlyPresented = parent?.presentedViewController as? UIAlertController {
            os_log("Refusing to present alert because already presenting: %@", log: ShowBikeViewController.log, type: .error, currentlyPresented.title!)
        } else {
            parent?.present(alert, animated: true)
        }
    }
}
