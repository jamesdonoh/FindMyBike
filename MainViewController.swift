//
//  MainViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 16/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: Properties

    weak var statusViewController: StatusViewController?
    weak var rangingTableViewController: RangingTableViewController?

    // Store references to our child view controllers when embed segue occurs
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statusViewController = segue.destination as? StatusViewController {
            self.statusViewController = statusViewController
        } else if let rangingTableViewController = segue.destination as? RangingTableViewController {
            self.rangingTableViewController = rangingTableViewController
        }
    }

    override func viewDidLoad() {
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.rangingTableViewController?.bikes = ["Honda", "Yamama", "Triumph"]
        }
    }

    // NOTE TO SELF
    // Do not waste 2h fiddling around with auto layout. Get more functionality going first then come back to it!
}
