//
//  ActivityView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 14/06/26.
//

import SwiftUI
import FirebaseFirestore // 🌟 Ditambahkan untuk mengambil real-time event dari Cloud
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
    
    // Filter cloud event berdasarkan tab yang dipilih
    private var filteredEvents: [CloudEvent] {
        let now = Date()
        
        switch selectedTab {
        case .yourActivity:
            // Event yang akan datang DAN ID user terdaftar di dalam array participants cloud
            return allEvents.filter { event in
                event.date >= now && event.participants.contains(currentUserID)
            }
            
        case .inGame:
            // Event yang sedang berlangsung saat ini
            return allEvents.filter { event in
                now >= event.date && now <= event.endTime
            }
            
        case .history:
            // Event yang sudah selesai lewat dari endTime
            return allEvents.filter { event in
                event.endTime < now
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header Title
                HStack {
                    Text("Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Custom Segmented Picker
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
                
                // List Events
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
                                // 🌟 Oper data CloudEvent dan ID user aktif ke halaman Detail baru
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
        // 🌟 Sinkronisasi real-time snapshot dari Firestore collection "events"
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
