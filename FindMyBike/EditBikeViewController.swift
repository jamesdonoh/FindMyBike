//
//  EditBikeViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

class EditBikeViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: Properties

    static let saveBikeSegueIdentifier = "saveBike"
    static let setColourSegueIdentifier = "setColour"

    let colourPrompt = "Tap to set"

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: EditBikeViewController.self))

    // Used for exchange of bike data with ShowBikeViewController
    var bike: Bike?

    var colour: Colour? {
        didSet {
            colourLabel.text = colour?.description ?? colourPrompt
            colourSwatch.textColor = colour?.ui ?? UIColor.clear
        }
    }

    // Used to store new bike details temporarily after validation
    private var validatedBike: Bike?

    @IBOutlet weak var makeTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!

    @IBOutlet weak var colourLabel: UILabel!
    @IBOutlet weak var colourSwatch: UILabel!

    @IBOutlet weak var beaconUUIDTextField: UITextField!
    @IBOutlet weak var beaconMajorTextField: UITextField!
    @IBOutlet weak var beaconMinorTextField: UITextField!

    @IBOutlet weak var missingSwitch: UISwitch!

    @IBOutlet weak var photoImageView: UIImageView!

    weak var photoAspectRatioConstraint: NSLayoutConstraint!

    // MARK: UIViewController

    override func viewDidLoad() {
        os_log("viewDidLoad", log: log, type: .debug)

        super.viewDidLoad()

        // Handle user input in the text fields through delegate callbacks
        makeTextField.delegate = self
        modelTextField.delegate = self
        beaconUUIDTextField.delegate = self
        beaconMajorTextField.delegate = self
        beaconMinorTextField.delegate = self

        colourLabel.text = colourPrompt
        missingSwitch.isOn = false

        // NB at the moment only one beacon UUID and major is supported
        beaconUUIDTextField.text = Constants.applicationUUID.uuidString
        beaconMajorTextField.text = String(Constants.applicationMajor)

        populateViewWithBike()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let identifier = segue.identifier else {
            fatalError("Missing segue identifier")
        }

        if identifier == EditBikeViewController.saveBikeSegueIdentifier {
            // shouldPerformSegue has already done the necessary validation, so we just pass it back
            bike = validatedBike
        } else if identifier == EditBikeViewController.setColourSegueIdentifier,
            let navigationController = segue.destination as? UINavigationController,
            let colourTableViewController = navigationController.topViewController as? ColourTableViewController {
            colourTableViewController.selectedColour = colour
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == EditBikeViewController.setColourSegueIdentifier {
            return true
        }

        do {
            try validatedBike = createBikeFromView()
            os_log("Created bike instance: %@", log: log, type: .error, validatedBike!.description)
            return true
        } catch let error as Bike.ValidationError {
            let alert = AlertFactory.generic(title: error.title, message: error.description)
            parent?.present(alert, animated: true)

            return false
        } catch {
            os_log("Unexpected error creating bike: %@", log: log, type: .error, error.localizedDescription)
            return false
        }
    }

    // MARK: Actions

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        guard let owningNavigationController = navigationController else {
            fatalError("Not inside a navigation controller")
        }

        owningNavigationController.popViewController(animated: true)
    }

    @IBAction func choosePhoto() {
        // Hide the keyboard
        view.endEditing(false)

        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self

        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func unwindToEditBike(sender: UIStoryboardSegue) {
        os_log("unwindToEditBike", log: log, type: .debug)

        if let source = sender.source as? ColourTableViewController {
            colour = source.selectedColour
        }
    }

    @IBAction func missingSwitchFlipped(_ sender: UISwitch) {
        os_log("missingSwitchFlipped, now: %@", log: log, type: .debug, String(missingSwitch.isOn))

        if missingSwitch.isOn {
            let alert = AlertFactory.confirmBikeMissing()
            parent?.present(alert, animated: true)
        }
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected an image from the picker")
        }

        updatePhotoImage(photo: selectedImage)

        dismiss(animated: true, completion: nil)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }

    // MARK: Private methods

    private func populateViewWithBike() {
        if let bike = bike {
            os_log("populateViewWithBike: %@", log: log, type: .debug, bike.description)

            makeTextField.text = bike.make
            modelTextField.text = bike.model
            colour = bike.colour

            beaconMinorTextField.text = String(bike.beaconMinor)

            missingSwitch.isOn = bike.isMissing

            if let photo = bike.photo {
                updatePhotoImage(photo: photo)
            }
        }
    }

    private func createBikeFromView() throws -> Bike {
        let make = makeTextField.text ?? ""
        let model = modelTextField.text ?? ""

        let beaconUUIDStr = beaconUUIDTextField.text ?? ""
        let beaconMajorStr = beaconMajorTextField.text ?? ""
        let beaconMinorStr = beaconMinorTextField.text ?? ""

        let isMissing = missingSwitch.isOn

        let photo = photoImageView.image

        // Preserve existing ID, if any
        let id = bike?.id

        // Use device token obtained by AppDelegate in didRegisterForRemoteNotificationsWithDeviceToken
        // TODO find a safer/more elegant way of obtaining this value
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let deviceToken = appDelegate.deviceToken

        return try Bike(make: make, model: model, colour: colour, beaconUUIDStr: beaconUUIDStr, beaconMajorStr: beaconMajorStr, beaconMinorStr: beaconMinorStr, isMissing: isMissing, photo: photo, id: id, deviceToken: deviceToken)
    }

    // Updates the photo image view, programmatically creating a new aspect ratio constraint
    // to allow the image view to remain flush with the controls above it. Without this, the 
    // height of the image view tries to grow to match the actual image height.
    //
    // Note: this has to be destructive because multipler is a read-only constraint property
    //
    private func updatePhotoImage(photo: UIImage) {
        // If there was an existing constraint, deactivate it before replacing
        if photoAspectRatioConstraint != nil {
            photoAspectRatioConstraint.isActive = false
        }

        let aspectRatio = photo.size.width / photo.size.height
        photoAspectRatioConstraint = NSLayoutConstraint(item: photoImageView, attribute: .width, relatedBy: .equal, toItem: photoImageView, attribute: .height, multiplier: aspectRatio, constant: 0)

        // Priority should be less than required constraint limiting height to guide bottom (1000)
        photoAspectRatioConstraint.priority = 749

        photoImageView.addConstraint(photoAspectRatioConstraint)
        photoImageView.image = photo
    }
}
