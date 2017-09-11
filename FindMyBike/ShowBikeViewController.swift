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
    
    var bike: Bike? {
        willSet {
            if let newBike = newValue {
                bikeLabel.text = "\(newBike)"
                photoImageView.image = newBike.photo
            }
        }
    }

    @IBOutlet weak var bikeLabel: UILabel!

    // MARK: UIViewController

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
