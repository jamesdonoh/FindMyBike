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

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ColourTableViewController.self))

    let reuseIdentifier = "ColourTableViewCell"

    let colours = ["Black", "Red", "Blue", "Green", "White"]

    var currentColour: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colours.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as UITableViewCell

        cell.textLabel!.text = colours[indexPath.row]

        return cell
    }

    // MARK: Selection

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("Non-existent cell selected")
        }

        os_log("didSelectRowAt: %lu", log: log, type: .debug, indexPath.row)

        tableView.deselectRow(at: indexPath, animated: false)

        if currentColour != nil, let oldIndex = colours.index(of: currentColour!) {
            if oldIndex == indexPath.row {
                return
            }
            guard let oldCell = tableView.cellForRow(at: IndexPath(row: oldIndex, section: 0)) else {
                fatalError("Previous selected colour does not exist in table")
            }
            oldCell.accessoryType = UITableViewCellAccessoryType.none
        }

        cell.accessoryType = UITableViewCellAccessoryType.checkmark
        currentColour = colours[indexPath.row]
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
