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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table cell views are reused and should be dequeued using a cell identifier
        let cellIdentifier = "RangingTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RangingTableViewCell else {
            fatalError("The dequeued call is not an instance of \(cellIdentifier)")
        }

        cell.nameLabel.text = "Cell \(indexPath.row)"

        return cell
    }
}
