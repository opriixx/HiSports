//
//  EventManager.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class EventManager {
    static let shared = EventManager()
    private let db = Firestore.firestore()
    
    private init() {}

    func createEvent(
        title: String,
        sport: String,
        location: String,
        date: Date,
        endTime: Date,
        price: Int,
        maxParticipants: Int,
        skillLevel: SkillLevel,
        equipment: [String],
        dressCode: DressCode,
        notes: String,
        aboutGame: String,
        imageName: String?
    ) async throws {
        //ID user = login?
        guard let currentUser = AuthManager.shared.currentUser else {
            throw NSError(domain: "EventManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Lu belum login, wan."])
        }
        
        let collectionRef = db.collection("events")
        let newEvent = CloudEvent(
            title: title,
            sport: sport,
            location: location,
            date: date,
            endTime: endTime,
            price: price,
            maxParticipants: maxParticipants,
            skillLevel: skillLevel.rawValue,
            equipment: equipment,
            dressCode: dressCode.rawValue,
            notes: notes,
            aboutGame: aboutGame,
            imageName: imageName,
            creatorId: currentUser.uid,
            participants: [currentUser.uid]
        )
        try collectionRef.addDocument(from: newEvent)
    }
    
    func listenToEvents(completion: @escaping (Result<[CloudEvent], Error>) -> Void) -> ListenerRegistration {
        return db.collection("events")
            .order(by: "date", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                //decod to Array of CloudEvent
                let events = documents.compactMap { doc -> CloudEvent? in
                    try? doc.data(as: CloudEvent.self)
                }
                completion(.success(events))
            }
    }
    
    func updateEvent(eventId: String, updatedEvent: CloudEvent) async throws {
        let eventRef = db.collection("events").document(eventId)
        try eventRef.setData(from: updatedEvent, merge: true)
    }
    
    func deleteEvent(eventId: String) async throws {
        try await db.collection("events").document(eventId).delete()
    }
    

    func joinEvent(eventID: String) async throws {
        let userID = Auth.auth().currentUser?.uid ?? ""
        let db = Firestore.firestore()
        
        try await db.collection("events").document(eventID).updateData([
            "participants": FieldValue.arrayUnion([userID])
        ])
    }

    func leaveEvent(eventId: String) async throws {
        guard let currentUid = AuthManager.shared.currentUser?.uid else { return }
        let eventRef = db.collection("events").document(eventId)
        
        try await eventRef.updateData([
            "participants": FieldValue.arrayRemove([currentUid])
        ])
    }
}
