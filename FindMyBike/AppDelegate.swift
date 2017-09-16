//
//  AppDelegate.swift
//  FindMyBike
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties

    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: AppDelegate.self))

    var window: UIWindow?

    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        os_log("didFinishLaunchingWithOptions", log: AppDelegate.log, type: .debug)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        os_log("applicationWillResignActive", log: AppDelegate.log, type: .debug)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        os_log("applicationDidBecomeActive", log: AppDelegate.log, type: .debug)
    }
}

