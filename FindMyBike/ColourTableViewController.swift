//
//  ColourTableViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 28/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

class ColourTableViewController: UITableViewController {

    static let unwindToEditBikeSegueIdentifier = "unwindToEditBike"

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ColourTableViewController.self))

    let reuseIdentifier = "ColourTableViewCell"

    var selectedColour: Colour?

    var selectedRow: Int? {
        guard let colour = selectedColour else {
            return nil
        }

        return Colour.all.index(of: colour)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Colour.all.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as UITableViewCell

        cell.textLabel!.text = Colour.all[indexPath.row].description
        if indexPath.row == selectedRow {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }

        return cell
    }

    // MARK: Selection

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("Non-existent cell selected")
        }

        os_log("didSelectRowAt: %lu", log: log, type: .debug, indexPath.row)

        tableView.deselectRow(at: indexPath, animated: false)

        if let oldRow = selectedRow {
            if indexPath.row == oldRow {
                return
            }
            guard let oldCell = tableView.cellForRow(at: IndexPath(row: oldRow, section: 0)) else {
                fatalError("Selected colour does not exist in table")
            }
            oldCell.accessoryType = UITableViewCellAccessoryType.none
        }

        cell.accessoryType = UITableViewCellAccessoryType.checkmark
        selectedColour = Colour.all[indexPath.row]

        performSegue(withIdentifier: ColourTableViewController.unwindToEditBikeSegueIdentifier, sender: self)
    }

    // MARK: Navigation

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
}
