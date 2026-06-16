//
//  EventDetailViewModel.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 14/06/26.
//

import Foundation
import FirebaseFirestore

@Observable
class EventDetailViewModel {
    // 1. Ubah tipe data menjadi CloudEvent (Firebase Model)
    var event: CloudEvent
    
    // Untuk current user login, kita simpan ID-nya saja supaya gampang nge-track matching data cloud
    var currentUserID: String?

    // Init menerima model CloudEvent dan ID user aktif
    init(event: CloudEvent, currentUserID: String? = nil) {
        self.event = event
        self.currentUserID = currentUserID
    }

    // Pengecekan apakah user aktif adalah pembuat event
    var isCreator: Bool {
        guard let userID = currentUserID else { return false }
        return event.creatorId == userID
    }

    // Pengecekan participant berdasarkan Array ID String dari Cloud
    var isParticipant: Bool {
        guard let userID = currentUserID else { return false }
        return event.participants.contains(userID)
    }

    // Pengecekan slot penuh berdasarkan jumlah item di array participants cloud
    var isFull: Bool {
        event.participants.count >= event.maxParticipants
    }

    var duration: String {
        let diff = Calendar.current.dateComponents(
            [.hour, .minute],
            from: event.date,
            to: event.endTime
        )
        let h = diff.hour ?? 0
        let m = diff.minute ?? 0
        if h > 0 && m > 0 { return "\(h) Hour \(m) Minutes" }
        if h > 0 { return "\(h) Hour" }
        return "\(m) Minutes"
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM yyyy"
        f.locale = Locale(identifier: "id_ID")
        return f.string(from: event.date)
    }

    var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "HH.mm"
        return "\(f.string(from: event.date)) - \(f.string(from: event.endTime))"
    }

    var formattedPrice: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "IDR"
        f.maximumFractionDigits = 0
        return (f.string(from: NSNumber(value: event.price)) ?? "Rp \(event.price)") + " / person"
    }

    var remainingSlots: Int {
        event.maxParticipants - event.participants.count
    }
    
    var currentParticipantsCount: Int {
        event.participants.count
    }

    func sportEmoji(for sport: String) -> String {
        Sport.defaultSports.first { $0.name == sport }?.emoji ?? "🏅"
    }
    
    func joinEvent() {
        guard let eventID = event.id, let userID = currentUserID, !isParticipant, !isFull else { return }

        // UI update duluan secara lokal (Optimistic Update)
        event.participants.append(userID)

        Task {
            do {
                // Tembak langsung dokumennya ke Firestore untuk nambahin ID ke array participants
                let db = FirebaseFirestore.Firestore.firestore()
                try await db.collection("events").document(eventID).updateData([
                    "participants": FirebaseFirestore.FieldValue.arrayUnion([userID])
                ])
                
                NotificationManager.shared.sendJoinEventNotification(eventName: event.title)
                
            } catch {
                print("Gagal join event di server: \(error.localizedDescription)")
                await MainActor.run {
                    event.participants.removeAll { $0 == userID }
                }
            }
        }
    }

    // Fungsi Leave Event versi Cloud Firestore Async-Throws
    func leaveEvent() {
        guard let eventID = event.id, let userID = currentUserID, isParticipant else { return }

        // UI update duluan secara lokal
        event.participants.removeAll { $0 == userID }

        Task {
            do {
                let db = FirebaseFirestore.Firestore.firestore()
                try await db.collection("events").document(eventID).updateData([
                    "participants": FirebaseFirestore.FieldValue.arrayRemove([userID])
                ])
                
                NotificationManager.shared.sendLeaveEventNotification(eventName: event.title)
                
            } catch {
                print("Gagal leave event di server: \(error.localizedDescription)")
                await MainActor.run {
                    event.participants.append(userID)
                }
            }
        }
    }
}
