//
//  NotificationItem.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 15/06/26.
//

import Foundation

class NotificationItem: Identifiable {
    let id = UUID()
    var title: String
    var message: String
    var date: Date
    var isRead: Bool
    var type: NotificationType

    init(title: String, message: String, date: Date = .now, isRead: Bool = false, type: NotificationType) {
        self.title = title
        self.message = message
        self.date = date
        self.isRead = isRead
        self.type = type
    }
}
