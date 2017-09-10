//
//  ShowBikeViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

class ShowBikeViewController: UIViewController {

    // MARK: Properties

    var bike: Bike? {
        willSet {
            bikeLabel.text = "\(newValue!)"
        }
    }

    @IBOutlet weak var bikeLabel: UILabel!

    // MARK: UIViewController

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let editBikeViewController = segue.destination as? EditBikeViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }

        editBikeViewController.bike = bike
    }

    @IBAction func unwindToShowBike(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditBikeViewController, let bike = sourceViewController.bike {
            self.bike = bike
        }
    }
}
