//
//  UserManager.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import Foundation
import FirebaseFirestore

@Observable
class UserManager {
    static let shared = UserManager()
    
    var profile: UserProfile? = nil
    var isLoading = false
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchProfile(uid: String) async {
        isLoading = true
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if doc.exists {
                profile = try doc.data(as: UserProfile.self)
            } else {
                profile = nil
            }
        } catch {
            print("Gagal fetch profile: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        try db.collection("users").document(profile.uid).setData(from: profile, merge: true)
        self.profile = profile
    }
    
    func clearProfile() {
        profile = nil
    }
    
    func updateTotalMatches(uid: String) async {
        do {
            let snapshot = try await db.collection("events")
                .whereField("participants", arrayContains: uid)
                .getDocuments()
            
            let now = Date()
            let pastEvents = snapshot.documents.filter { doc in
                if let timestamp = doc.data()["endTime"] as? Timestamp {
                    return timestamp.dateValue() < now
                }
                return false
            }
            
            try await db.collection("users").document(uid).updateData([
                "totalMatches": pastEvents.count
            ])
            
            self.profile?.totalMatches = pastEvents.count
        } catch {
            print("Gagal update total matches: \(error.localizedDescription)")
        }
    }
}
