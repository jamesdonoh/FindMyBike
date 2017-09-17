//
//  MainViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 16/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

class MainViewController: AppEventViewController {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: MainViewController.self))

    let bikeRegistry = BikeRegistry()

    let proximityMonitor = ProximityMonitor()

    weak var statusViewController: StatusViewController?
    weak var rangingTableViewController: RangingTableViewController?

    // MARK: UIViewController

    override func viewDidLoad() {
        os_log("viewDidLoad", log: log, type: .debug)
        super.viewDidLoad()

        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.rangingTableViewController?.missingBikes = self.bikeRegistry.missingBikes
        }
    }

    // Store references to our child view controllers when embed segue occurs
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
    }

    override func applicationWillResignActive(_ notification: NSNotification!) {
        os_log("applicationWillResignActive", log: log, type: .debug)
    }

    // MARK: Private methods
}
