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

class RangingTableViewController: UITableViewController {

    // MARK: Properties

    let reuseIdentifier = "RangingTableViewCell"

    var missingItems = [(bike: Bike, proximity: String)]() {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? RangingTableViewCell else {
            fatalError("The dequeued call is not an instance of \(reuseIdentifier)")
        }

        let missingItem = missingItems[indexPath.row]
        cell.titleLabel.text = missingItem.bike.makeAndModel
        cell.subtitleLabel.text = missingItem.proximity
        cell.photoImageView.image = missingItem.bike.photo

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?

        if missingItems.count > 0 {
            title = "Missing bikes nearby"
            tableView.separatorStyle = .singleLine
        } else {
            title = "No bikes in range"
            tableView.separatorStyle = .none
        }

        return title
    }
}
