//
//  AuthViewModel.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import Observation
import FirebaseAuth
import FirebaseFirestore

@Observable
class AuthViewModel {
    var user: FirebaseAuth.User?
    var hasProfile: Bool = false
    var isCheckingProfile: Bool = true

    init() {
        self.user = Auth.auth().currentUser

        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if let user = user {
                Task {
                    await self.checkProfile(uid: user.uid)
                }
            } else {
                // Reset semua saat logout
                UserManager.shared.clearProfile()
                self.hasProfile = false
                self.isCheckingProfile = false
            }
        }
    }

    func checkProfile(uid: String) async {
        do {
            let doc = try await Firestore.firestore().collection("users").document(uid).getDocument()
            await MainActor.run {
                self.hasProfile = doc.exists
                self.isCheckingProfile = false
            }
        } catch {
            await MainActor.run {
                self.hasProfile = false
                self.isCheckingProfile = false
            }
        }
    }
    
    func refreshProfile() async {
        guard let uid = user?.uid else { return }
        await checkProfile(uid: uid)
    }
}
