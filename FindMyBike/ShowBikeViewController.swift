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

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var proximityLabel: UILabel!

    var bike: Bike? {
        willSet {
            if let newBike = newValue {
                photoImageView.image = newBike.photo
                makeLabel.text = newBike.make
                modelLabel.text = newBike.model
                //proximityLabel.text = "Proximity: somewhere"

                view.backgroundColor = UIColor.white
            }
        }
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.image = nil
        makeLabel.text = nil
        modelLabel.text = nil
        proximityLabel.text = nil

        view.backgroundColor = UIColor.groupTableViewBackground
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let editBikeViewController = segue.destination as? EditBikeViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }

        // Temporary for testing
        //editBikeViewController.bike = bike
        editBikeViewController.bike = bike ?? Bike()
    }

    @IBAction func unwindToShowBike(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditBikeViewController, let bike = sourceViewController.bike {
            self.bike = bike
        }
    }
}
