//
//  RangingTableViewController.swift
//
//  A TableViewController subclass
//
//  FindMyBike
//
//  Created by James Donohue on 16/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

class RangingTableViewController: UITableViewController {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: RangingTableViewController.self))

    let reuseIdentifier = "RangingTableViewCell"

    var missingBikes = [(bike: Bike, proximity: String)]() {
        didSet {
            tableView.reloadData()
        }
    }

    weak var myBike: Bike? {
        didSet {
            tableView.reloadData()
        }
    }

    var myBikeProximity: String?

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let selectedBikeCell = sender as? RangingTableViewCell else {
            fatalError("Unexpected sender: \(sender!)")
        }

        guard let editBikeViewController = segue.destination as? EditBikeViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }

        guard let indexPath = tableView.indexPath(for: selectedBikeCell) else {
            fatalError("Selected cell is not displayed")
        }

        os_log("preparing to editBike: %@", log: log, type: .debug, indexPath.description)

        if indexPath.section == 0 {
            // My bike cell was tapped

            // Dummy data for testing
            editBikeViewController.bike = BikeRegistry().r1
        } else {
            // TODO handle tapping other rows
        }
    }

    @IBAction func unwindToRangingTable(sender: UIStoryboardSegue) {
        os_log("unwindToRangingTable", log: log, type: .debug)

        if let sourceViewController = sender.source as? EditBikeViewController, let bike = sourceViewController.bike {
            self.myBike = bike
        }
    }

    // MARK: TableView data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : missingBikes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? RangingTableViewCell else {
            fatalError("The dequeued call is not an instance of \(reuseIdentifier)")
        }

        //TODO simplify/restructure this
        if indexPath.section == 0 && myBike == nil {
            cell.titleLabel.text = "No bike configured"
            cell.subtitleLabel.text = "Tap to edit"
            cell.photoImageView.image = UIImage(named: "NoBikeIcon")

            return cell
        }

        var bike: (bike: Bike, proximity: String)
        if indexPath.section == 0 && myBike != nil {
            bike = (bike: myBike!, proximity: myBikeProximity ?? "Not in range")
        } else {
            bike = missingBikes[indexPath.row]
        }

        cell.titleLabel.text = bike.bike.makeAndModel
        cell.subtitleLabel.text = bike.proximity
        cell.photoImageView.image = bike.bike.photo

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My bike"
        } else {
            var title: String?

            if missingBikes.count > 0 {
                title = "Missing bikes nearby"
                tableView.separatorStyle = .singleLine
            } else {
                title = "No missing bikes detected"
                tableView.separatorStyle = .none
            }
            
            return title
        }
    }
}
