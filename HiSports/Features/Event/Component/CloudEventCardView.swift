//
//   CloudEventCardView.swift
//   HiSports
//
//   Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import SwiftUI

struct CloudEventCardView: View {
    let event: CloudEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                let sportImage: String = {
                    if let cloudImage = event.imageName, !cloudImage.isEmpty {
                        return cloudImage
                    }
                    let matchedSport = Sport.defaultSports.first { $0.name.lowercased() == event.sport.lowercased() }
                    return matchedSport?.imageName ?? "badminton"
                }()
                
                Image(sportImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.init(top: 12, leading: 12, bottom: 0, trailing: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                    Spacer()
                    Text("Rp\(event.price) / pax")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Image(systemName: "building.2.fill")
                        .font(.footnote)
                    Text(event.location)
                        .font(.footnote)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.footnote)
                    
                    Text(event.date.formatted(
                        .dateTime
                            .day()
                            .month(.wide)
                            .year()
                            .hour().minute()
                    ))
                    .font(.footnote)
                    
                    Text("-")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Text(event.endTime.formatted(.dateTime.hour().minute()))
                        .font(.footnote)
                }
                
                HStack {
                    Image(systemName: "person.3.fill") // Diganti biar iconnya lebih nyambung sama kuota orang
                        .font(.footnote)
                    // Menampilkan jumlah peserta yang join saat ini dari total kuota
                    Text("\(event.currentParticipantsCount) / \(event.maxParticipants) orang")
                        .font(.footnote)
                }
                
            }
            .padding(.init(top: 0, leading: 12, bottom: 12, trailing: 12))
            
        }
        .background(Color("White-500"))
        .cornerRadius(24)
    }
}
