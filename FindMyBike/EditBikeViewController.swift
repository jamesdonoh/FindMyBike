//
//  EditBikeViewController.swift
//  FindMyBike
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

class EditBikeViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties

    var bike: Bike?

    @IBOutlet weak var makeTextField: UITextField!

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle user input in the text field through delegate callbacks
        makeTextField.delegate = self

        if let bike = bike {
            makeTextField.text = bike.make
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        let make = makeTextField.text ?? ""

        bike = Bike()
        if !make.isEmpty {
            bike!.make = make
        }
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        guard let owningNavigationController = navigationController else {
            fatalError("Not inside a navigation controller")
        }

        owningNavigationController.popViewController(animated: true)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
}
