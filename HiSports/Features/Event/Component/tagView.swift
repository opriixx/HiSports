//
//  tagView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 11/06/26.
//

import SwiftUI

enum SportType: String {
    case badminton = "Badminton"
    case futsal = "Futsal"
    case basket = "Basket"

    var color: Color {
        switch self {
        case .badminton:
            return Color("TagBadmintonColor")
        case .futsal:
            return Color("TagFutsalColor")
        case .basket:
            return Color("TagBasketColor")
        }
    }
}
