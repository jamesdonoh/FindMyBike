//
//  AppDelegate.swift
//  FindMyBike
//
//  Created by James Donohue on 10/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UIKit
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: Properties

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: AppDelegate.self))

    var window: UIWindow?

    var deviceToken: String?

    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        os_log("didFinishLaunchingWithOptions", log: log, type: .debug)
        os_log("vendor ID = %@", log: log, type: .info, UIDevice.current.identifierForVendor?.description ?? "(none)")

        // Register for push notifications via APNs - note mandatory to use AppDelegate
        UIApplication.shared.registerForRemoteNotifications()

        // Assign delegate for user notifications - must be done before application finishes launching
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        os_log("applicationWillResignActive", log: log, type: .debug)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        os_log("applicationDidBecomeActive", log: log, type: .debug)
    }

    // MARK: Remote notification registration

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        os_log("Registered for remote notifications", log: log, type: .info)

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        os_log("Device token: %@", log: log, type: .info, token)

        self.deviceToken = token
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("Remote notifications not available: %@", log: log, type: .error, error.localizedDescription)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        os_log("Received remote notification: %@", log: log, type: .info, userInfo)
        completionHandler(.newData)
    }

    // MARK: UNUserNotificationCenterDelegate

    // Called when app is in foreground
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        os_log("willPresent: %@", log: log, type: .info, notification.request.content.body)
//
//        completionHandler(UNNotificationPresentationOptions.alert)
//    }

    // Called when app is in background and the user performs an action
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        os_log("didReceive: %@", log: log, type: .info, content.body)

        guard let latitude = content.userInfo["latitude"] as? Double,
            let longitude = content.userInfo["longitude"] as? Double else {
            fatalError("Missing/invalid coordinates in notification")
        }

        os_log("Sighting at: %f,%f", log: log, type: .info, latitude, longitude)

        completionHandler()
    }
}
