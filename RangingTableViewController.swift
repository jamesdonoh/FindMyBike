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

    var bikes = [String]() {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bikes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? RangingTableViewCell else {
            fatalError("The dequeued call is not an instance of \(reuseIdentifier)")
        }

        cell.titleLabel.text = bikes[indexPath.row]
        cell.subtitleLabel.text = "Far"
        cell.photoImageView.image = UIImage(named: "bike" + String(indexPath.row + 1))

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?

        if bikes.count > 0 {
            title = "Missing bikes nearby"
            tableView.separatorStyle = .singleLine
        } else {
            title = "No bikes in range"
            tableView.separatorStyle = .none
        }

        return title
    }

    // MARK: Private methods

    private func updateBackround() {
        if bikes.count > 0 {
            tableView.backgroundView = nil
        } else {
            tableView.backgroundView = UILabel()
        }
    }
}
