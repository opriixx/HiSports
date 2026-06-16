//
//  SportModel.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 12/06/26.
//

import Foundation

struct Sport: Identifiable {
    let id = UUID()
    var name: String
    var emoji: String
    var imageName: String
    var availableEquipments: [String]

    static let defaultSports: [Sport] = [
        Sport(name: "Badminton", emoji: "🏸", imageName: "badminton", availableEquipments: ["Net", "Shuttlecock", "Racket", "Badminton Shoes"]),
        Sport(name: "Basketball", emoji: "🏀", imageName: "Basketball", availableEquipments: ["Basketball", "Jersey", "Basketball Shoes"]),
        Sport(name: "Football", emoji: "⚽️", imageName: "Football", availableEquipments: ["Soccer Ball", "Soccer Cleats", "Shin Guards", "Gooalkeeper Gloves"]),
        Sport(name: "Tennis", emoji: "🎾", imageName: "Tennis", availableEquipments: ["Tennis Racket", "Tennis Balls", "Tennis Shoes"]),
        Sport(name: "Volleyball", emoji: "🏐", imageName: "Volleyball", availableEquipments: ["Volleyball", "Knee Pads", "Volleyball Shoes"]),
        Sport(name: "Mini Soccer", emoji: "⚽", imageName: "Mini Soccer", availableEquipments: ["Ball", "Cleats", "Shin Guards", "Gooalkeeper Gloves"])
    ]
}
