//
//  UserManager.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

@Observable
class UserManager {
    static let shared = UserManager()
    
    var profile: UserProfile? = nil
    var isLoading = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    // Ambil profile dari Firestore
    func fetchProfile(uid: String) async {
        isLoading = true
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if doc.exists {
                profile = try doc.data(as: UserProfile.self)
            }
        } catch {
            print("Gagal fetch profile: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // Simpan / update profile ke Firestore
    func saveProfile(_ profile: UserProfile) async throws {
        try db.collection("users").document(profile.uid).setData(from: profile, merge: true)
        self.profile = profile
    }
    
    // Upload foto ke Firebase Storage, return URL string
    func uploadPhoto(uid: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "UserManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Gagal convert foto"])
        }
        
        let ref = storage.reference().child("profile_photos/\(uid).jpg")
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    // Hitung total matches dari events yang sudah lewat
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
