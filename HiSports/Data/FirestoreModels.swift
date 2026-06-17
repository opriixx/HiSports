import Foundation
import FirebaseFirestore

struct CloudEvent: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var sport: String
    var location: String
    var date: Date
    var endTime: Date
    var price: Int
    var maxParticipants: Int
    var skillLevel: String
    var equipment: [String]
    var dressCode: String
    var notes: String
    var aboutGame: String
    var imageName: String? = nil
    
    var creatorId: String
    var participants: [String] = []    
    
    var currentParticipantsCount: Int {
        return participants.count
    }
}
