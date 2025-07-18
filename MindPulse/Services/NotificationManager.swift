//
//  NotificationManager.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/14/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification auth error:", error)
            return false
        }
    }
    
    func scheduleDailyReminder(
        id: String = "mindpulse.journal.reminder",
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Scheduling error:", error)
            } else {
                print("Scheduled daily reminder at \(hour):\(minute)")
            }
        }
    }

}

