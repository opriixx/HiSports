//
//  ActivityEventCard.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 14/06/26.
//

import SwiftUI
import FirebaseFirestore

struct ActivityEventCard: View {
    let event: CloudEvent
    
    private var remainingSlots: Int {
        max(0, event.maxParticipants - event.participants.count)
    }
    
    private var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        let start = formatter.string(from: event.date)
        let end = formatter.string(from: event.endTime)
        return "\(start) - \(end)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Badge Skill / Level
                Text(event.skillLevel.capitalized)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(colorSkiil(event.skillLevel))
                    .foregroundColor(event.skillLevel.lowercased() == "intermediate" ? .orange : .green)
                    .cornerRadius(6)

                Text(event.sport)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(6)
                
                Spacer()

                Text("\(remainingSlots) slot tersisa")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Color.blue.opacity(0.2)
                    Text(sportEmoji(for: event.sport))
                        .font(.title)
                }
                .frame(width: 65, height: 65)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "building.2")
                            .font(.caption)
                        Text(event.location)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text(formattedTimeRange)
                                .font(.caption)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.caption)
                            Text("\(event.participants.count) Orang")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color("White-500"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
    
    private func sportEmoji(for sport: String) -> String {
        switch sport.lowercased() {
        case "badminton", "bulutangkis": return "🏸"
        case "basketball": return "🏀"
        default: return "⚽️"
        }
    }
    
    private func colorSkiil(_ level: String) -> Color {
        switch level.lowercased() {
        case "beginner": return Color.green.opacity(0.15)
        case "intermediate": return Color.orange.opacity(0.15)
        case "expert": return Color.red.opacity(0.15)
        default: return Color.gray.opacity(0.15)
        }
    }
}

#Preview {
    ActivityEventCard(
        event: CloudEvent(
            id: "preview_id",
            title: "Jakarta Basketball Cloud",
            sport: "Basketball",
            location: "Agora Sports Hall",
            date: Date(),
            endTime: Date().addingTimeInterval(7200),
            price: 50000,
            maxParticipants: 15,
            skillLevel: "Beginner",
            equipment: ["Bola"],
            dressCode: "Sportswear",
            notes: "Catatan dummy cloud",
            aboutGame: "Main seru-seruan bareng anak-anak",
            imageName: nil,
            creatorId: "dummy_user_id",
            participants: ["dummy_user_id"]
        )
    )
}
