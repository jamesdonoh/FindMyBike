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

protocol BikeChangeDelegate: class {
    func myBikeChanged(newBike: Bike?)
}

class RangingTableViewController: UITableViewController {

    // MARK: Properties

    static let editBikeSegueIdentifier = "editBike"

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: RangingTableViewController.self))

    let reuseIdentifier = String(describing: RangingTableViewCell.self)

    let monoBikeIcon = UIImage(named: "MonoBikeIcon")
    let defaultIconColour = UIColor.lightGray

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

    weak var delegate: BikeChangeDelegate?

    var myBikeProximity: String?

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let editBikeViewController = segue.destination as? EditBikeViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }

        editBikeViewController.bike = myBike
    }

    @IBAction func unwindToRangingTable(sender: UIStoryboardSegue) {
        os_log("unwindToRangingTable", log: log, type: .debug)

        if let sourceViewController = sender.source as? EditBikeViewController, let bike = sourceViewController.bike {
            self.myBike = bike

            // Propagate bike change to parent for persistence (we only have weak ref)
            delegate?.myBikeChanged(newBike: myBike)
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

        cell.photoImageView.image = monoBikeIcon
        cell.photoImageView.tintColor = defaultIconColour

        //TODO simplify/restructure this
        if indexPath.section == 0 && myBike == nil {
            cell.titleLabel.text = "Not configured"
            cell.subtitleLabel.text = "Tap to edit"
        } else {
            var bike: (bike: Bike, proximity: String)
            if indexPath.section == 0 && myBike != nil {
                bike = (bike: myBike!, proximity: myBikeProximity ?? "Not in range")
            } else {
                bike = missingBikes[indexPath.row]
            }

            cell.titleLabel.text = bike.bike.makeAndModel
            cell.subtitleLabel.text = bike.proximity

            if let colour = bike.bike.colour {
                cell.photoImageView.tintColor = colour.ui
            }
            if let photo = bike.bike.photo {
                cell.photoImageView.image = photo
            }
        }

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

    // MARK: UITableViewController

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: RangingTableViewController.editBikeSegueIdentifier, sender: self)
        default:
            os_log("selected other row", log: log, type: .debug)
        }
    }
}
