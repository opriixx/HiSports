//
//  AuthManager.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 15/06/26.
//

import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    func signUp(email: String, password: String) async throws -> AuthDataResult {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "AuthManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email and password cannnot be empty."])
        }

        return try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "AuthManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty."])
        }
        
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
 
    func signOut() throws {
        try Auth.auth().signOut()
    }

    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
}
