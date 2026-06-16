//
//  Enums.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import Foundation

enum SkillLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case expert = "Expert"
}

enum DressCode: String, Codable, CaseIterable {
    case casual = "Casual"
    case Jersey = "Jersey"
    case Sportswear = "Sportswear"
    case formal = "Formal"
}
