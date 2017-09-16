//
//  ShowBikeViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

class ShowBikeViewController: AppEventViewController, RangingDelegate {

    // MARK: Properties

    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ShowBikeViewController.self))

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
        os_log("viewDidLoad", log: ShowBikeViewController.log, type: .debug)

        super.viewDidLoad()

        photoImageView.image = nil
        makeLabel.text = nil
        modelLabel.text = nil
        proximityLabel.text = nil

        view.backgroundColor = UIColor.groupTableViewBackground
    }

    override func viewWillDisappear(_ animated: Bool) {
        if bike != nil {
            Ranging.sharedInstance.disableRanging()
        }
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

    // MARK: Actions

    @IBAction func unwindToShowBike(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditBikeViewController, let bike = sourceViewController.bike {
            self.bike = bike
            resetProximityLabel()

            Ranging.sharedInstance.delegate = self
            Ranging.sharedInstance.enableRanging(for: bike.region)
        }
    }

    // MARK: AppEventViewController

    override func applicationDidBecomeActive(_ notification: NSNotification!) {
        os_log("applicationDidBecomeActive", log: ShowBikeViewController.log, type: .debug)

        resetProximityLabel()
        Ranging.sharedInstance.startRanging()
    }

    override func applicationWillResignActive(_ notification: NSNotification!) {
        os_log("applicationWillResignActive", log: ShowBikeViewController.log, type: .debug)

        Ranging.sharedInstance.stopRanging()
    }

    func rangingNotAvailable() {
        tryToPresent(AlertFactory.makeRangingNotAvailableAlert())
        resetProximityLabel()
    }

    func rangingNotAuthorised() {
        tryToPresent(AlertFactory.makeRangingNotAuthorisedAlert())
        resetProximityLabel()
    }

    func bluetoothNotAvailable() {
        // Do not show alert here as we don't know if this state is just transient
        resetProximityLabel()
    }

    func didRangeBeacon(proximity: String) {
        os_log("didRangeBeacon: %@", log: ShowBikeViewController.log, type: .info, proximity)

        proximityLabel.text = "Detected. Proximity: \(proximity)"
    }

    // MARK: Private methods

    func tryToPresent(_ alert: UIAlertController) {
        if let currentlyPresented = parent?.presentedViewController as? UIAlertController {
            os_log("Refusing to present alert because already presenting: %@", log: ShowBikeViewController.log, type: .error, currentlyPresented.title!)
        } else {
            parent?.present(alert, animated: true)
        }
    }

    private func resetProximityLabel() {
        proximityLabel.text = defaultLabel()
    }

    private func defaultLabel() -> String {
        if !Ranging.sharedInstance.rangingAuthorised() {
            return "Not authorised to use Location Services"
        } else if !BluetoothSupport.sharedInstance.bluetoothAvailable() {
            return "Bluetooth is not available"
        } else {
            return "Searching for beacon..."
        }
    }
}
