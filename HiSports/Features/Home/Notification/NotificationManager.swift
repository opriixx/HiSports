//
//  NotificationManager.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 15/06/26.
//

//
//  NotificationManager.swift
//  HiSports
//

import Foundation
import UserNotifications

@Observable

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    var notifications: [NotificationItem] = []
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error { print(error.localizedDescription) }
                print("Permission:", granted)
            }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    @MainActor
    func sendNotification(title: String, body: String, type: NotificationType, seconds: Double = 1) {
        notifications.insert(NotificationItem(title: title, message: body, type: type), at: 0)
        
        let send = {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) // ← langsung panggil di sini
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                send()
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
                    if success { send() }
                }
            }
        }
    }
    
    @MainActor
    func sendJoinEventNotification(eventName: String) {
        sendNotification(title: "Berhasil Join Event! 🎉", body: "Kamu terdaftar di \(eventName)", type: .eventJoined)
    }
    
    @MainActor
    func sendLeaveEventNotification(eventName: String) {
        sendNotification(title: "Keluar dari Event", body: "Kamu keluar dari \(eventName)", type: .eventCancelled)
    }
    
    @MainActor
    func sendCreateEventNotification(eventName: String) {
        sendNotification(title: "Event Dibuat! 🏅", body: "\(eventName) berhasil dibuat", type: .system)
    }
}
