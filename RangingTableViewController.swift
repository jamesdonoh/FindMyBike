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

    static let reuseIdentifier = "RangingTableViewCell"

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
        let cell = tableView.dequeueReusableCell(withIdentifier: RangingTableViewController.reuseIdentifier, for: indexPath)

        cell.textLabel!.text = bikes[indexPath.row]
        cell.detailTextLabel!.text = "Far"
        //cell.imageView = foo

        return cell
    }
}
