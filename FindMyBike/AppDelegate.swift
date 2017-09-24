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

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: AppDelegate.self))

    var window: UIWindow?

    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        os_log("didFinishLaunchingWithOptions", log: log, type: .debug)
        os_log("vendor ID = %@", log: log, type: .info, UIDevice.current.identifierForVendor?.description ?? "(none)")

        // Register for push notifications via APNs
        UIApplication.shared.registerForRemoteNotifications()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        os_log("applicationWillResignActive", log: log, type: .debug)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        os_log("applicationDidBecomeActive", log: log, type: .debug)
    }

    // MARK: Remote notifications

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        os_log("Registered for remote notifications", log: log, type: .info)

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        os_log("Device token: %@", log: log, type: .info, token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("Remote notifications not available: %@", log: log, type: .error, error.localizedDescription)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        os_log("Received remote notification: %@", log: log, type: .info, userInfo)
        completionHandler(.newData)
    }
}

