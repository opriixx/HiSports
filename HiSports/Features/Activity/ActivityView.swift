//
//  ActivityView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 14/06/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum ActivityTab: String, CaseIterable {
    case yourActivity = "Your Activity"
    case inGame = "In-game"
    case history = "History"
}

struct ActivityView: View {
    @State private var selectedTab: ActivityTab = .yourActivity
    @State private var allEvents: [CloudEvent] = []
    @State private var listenerRegistration: ListenerRegistration? = nil

    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    private var filteredEvents: [CloudEvent] {
        let now = Date()
        
        switch selectedTab {
        case .yourActivity:
            return allEvents.filter { event in
                event.date >= now && event.participants.contains(currentUserID)
            }
            
        case .inGame:
            return allEvents.filter { event in
                now >= event.date && now <= event.endTime
            }
            
        case .history:
            return allEvents.filter { event in
                event.endTime < now
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    Text("Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    
                    NavigationLink {
                        CreateEventView()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .padding(.vertical, 8)
                        .background(.red, in: RoundedRectangle(cornerRadius: 50))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                HStack(spacing: 4) {
                    ForEach(ActivityTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? Color.white : Color.clear)
                            .clipShape(Capsule())
                            .shadow(color: selectedTab == tab ? .black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = tab
                                }
                            }
                    }
                }
                .padding(4)
                .background(Color(.systemGroupedBackground))
                .clipShape(Capsule())
                .padding(.horizontal)
                .padding(.top, 10)
                
                if filteredEvents.isEmpty {
                    ContentUnavailableView(
                        "No Events Found",
                        systemImage: "sportscourt",
                        description: Text("There are no matches listed in this section.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event, currentUserID: currentUserID)) {
                                    ActivityEventCard(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color("Base"))
        }

        .onAppear {
            self.listenerRegistration?.remove()
            
            let db = Firestore.firestore()
            self.listenerRegistration = db.collection("events")
                .order(by: "date", descending: false)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("Gagal mengambil live activity: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else { return }
                    
                    self.allEvents = documents.compactMap { doc -> CloudEvent? in
                        try? doc.data(as: CloudEvent.self)
                    }
                }
        }
        .onDisappear {
            self.listenerRegistration?.remove()
        }
    }
}

#Preview {
    ActivityView()
}
