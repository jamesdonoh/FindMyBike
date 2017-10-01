//
//  Notification.swift
//  FindMyBike
//
//  Created by James Donohue on 19/09/2017.
//  Copyright © 2017 James Donohue. All rights reserved.
//

import UserNotifications
import os.log

class Notifications {

    // MARK: Properties

    static let localIdentifier = "FMBLLocalNotification"

    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: Notifications.self))

    let center = UNUserNotificationCenter.current()

    // MARK: Initialisation

    init() {
        os_log("init", log: log, type: .debug)

        let options: UNAuthorizationOptions = [.alert]

        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                os_log("Error requesting authorisation", log: self.log, type: .error)
            }
        }
    }

    // MARK: Public interface

    func send(message: String) {
        center.getNotificationSettings() { (settings) in
            if settings.authorizationStatus != .authorized {
                os_log("Notifications not authorised", log: self.log, type: .error)
                // TODO try to reenable?
            }
        }

        let content = UNMutableNotificationContent()
        content.body = message

        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(identifier: Notifications.localIdentifier, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                os_log("Error adding notifiation: %@", log: self.log, type: .error, error.localizedDescription)
            }
        }
    }
}
