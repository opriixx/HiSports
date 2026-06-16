//
//  NotificationType.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 15/06/26.
//

import SwiftUI

enum NotificationType: String, Codable {

    case eventJoined
    case eventReminder
    case eventCancelled
    case promotion
    case system

    var details: (icon: String, color: Color) {

        switch self {

        case .eventJoined:
            return ("person.badge.plus", .green)

        case .eventReminder:
            return ("calendar.badge.clock", .blue)

        case .eventCancelled:
            return ("xmark.circle.fill", .red)

        case .promotion:
            return ("tag.fill", .pink)

        case .system:
            return ("bell.badge.fill", .orange)
        }
    }
}
