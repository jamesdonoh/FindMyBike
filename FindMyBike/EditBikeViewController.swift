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

    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: EditBikeViewController.self))

    static let saveBikeSegueIdentifier = "saveBike"

    // Used for exchange of bike data with ShowBikeViewController
    var bike: Bike?

    // Used to store new bike details temporarily after validation
    private var validatedBike: Bike?

    @IBOutlet weak var makeTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var beaconUUIDTextField: UITextField!
    @IBOutlet weak var beaconMajorTextField: UITextField!
    @IBOutlet weak var beaconMinorTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle user input in the text fields through delegate callbacks
        makeTextField.delegate = self
        modelTextField.delegate = self
        beaconUUIDTextField.delegate = self
        beaconMajorTextField.delegate = self
        beaconMinorTextField.delegate = self

        if let bike = bike {
            makeTextField.text = bike.make
            modelTextField.text = bike.model
            beaconUUIDTextField.text = bike.beaconUUID.uuidString
            beaconMajorTextField.text = String(bike.beaconMajor)
            beaconMinorTextField.text = String(bike.beaconMinor)
            photoImageView.image = bike.photo
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        assert(segue.identifier == EditBikeViewController.saveBikeSegueIdentifier)

        super.prepare(for: segue, sender: sender)

        // shouldPerformSegue has already done the necessary validation, so we just pass it back
        bike = validatedBike
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        assert(identifier == EditBikeViewController.saveBikeSegueIdentifier)

        do {
            try validatedBike = createBike()
            return true
        } catch let error as Bike.ValidationError {
            let alert = createErrorAlert(title: error.title, message: error.description)
            parent?.present(alert, animated: true)

            return false
        } catch {
            os_log("Unexpected error creating bike: %@", log: EditBikeViewController.log, type: .error, error.localizedDescription)
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

    // MARK: UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected an image from the picker")
        }

        print(selectedImage)
        photoImageView.image = selectedImage

        dismiss(animated: true, completion: nil)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }

    // MARK: Private methods

    private func createBike() throws -> Bike {
        let make = makeTextField.text ?? ""
        let model = modelTextField.text ?? ""
        let beaconUUIDStr = beaconUUIDTextField.text ?? ""
        let beaconMajorStr = beaconMajorTextField.text ?? ""
        let beaconMinorStr = beaconMinorTextField.text ?? ""
        let photo = photoImageView.image

        return try Bike(make: make, model: model, beaconUUIDStr: beaconUUIDStr, beaconMajorStr: beaconMajorStr, beaconMinorStr: beaconMinorStr, photo: photo)
    }

    private func createErrorAlert(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        return alertController
    }
}
