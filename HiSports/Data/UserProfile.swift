//
//  UserProfile.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable {
    var uid: String
    var name: String
    var favSports: String
    var skillLevel: String
    var photoURL: String?
    var totalMatches: Int
    
    init(uid: String, name: String = "", favSports: String = "", skillLevel: String = "Beginner", photoURL: String? = nil, totalMatches: Int = 0) {
        self.uid = uid
        self.name = name
        self.favSports = favSports
        self.skillLevel = skillLevel
        self.photoURL = photoURL
        self.totalMatches = totalMatches
    }
}
