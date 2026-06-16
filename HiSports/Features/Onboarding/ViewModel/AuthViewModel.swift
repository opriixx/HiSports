//
//  AuthViewModel.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import Observation
import FirebaseAuth

@Observable
class AuthViewModel {

    var user: FirebaseAuth.User?

    init() {
        self.user = Auth.auth().currentUser

        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
}
