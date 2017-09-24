//
//  AppEventViewController.swift
//  BeaconRanger
//
//  Generic ViewController that can receive app events such as switching between foreground
//  and background, to simplify AppDelegate
//
//  Note that the ViewController will not start receiving events until it is itself created
//  (i.e. after viewDidLoad), i.e. it will not receive the first applicationDidBecomeActive
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit

class AppEventViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: .UIApplicationWillResignActive, object: nil)
    }

    // Posted once the app is receiving events (equivalent to applicationDidBecomeActive in AppDelegate)
    func applicationDidBecomeActive(_ notification: NSNotification!) { }
    
    // Posted when the app loses focus (equivalen to applicationWillResignActive in AppDelegate)
    func applicationWillResignActive(_ notification: NSNotification!) { }

    deinit {
        // Remove self as notification observer when the controller is destroyed
        NotificationCenter.default.removeObserver(self)
    }
}
