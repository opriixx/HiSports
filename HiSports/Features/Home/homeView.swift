//  homeView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 10/06/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct homeView: View {
    @State private var selectedSports: [String] = []
    @State private var showSearch = false
    @State private var listEvent: [CloudEvent] = []
    @State private var listenerRegistration: ListenerRegistration? = nil
    @State private var userManager = UserManager.shared
    
    private var profile: UserProfile? { userManager.profile }
    
    private var filteredEvents: [CloudEvent] {
        let now = Date()
        let activeEvents = listEvent.filter { $0.endTime > now }
        
        guard !selectedSports.isEmpty else { return activeEvents }
        return activeEvents.filter { selectedSports.contains($0.sport) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile?.name.isEmpty == false ? "Hi, \(profile!.name)!" : "Hi, Athlete!")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(Date().formatted(
                            .dateTime
                                .weekday(.wide)
                                .day()
                                .month(.wide)
                                .year()
                        ))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: NotificationView()) {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }

                Button {
                    showSearch = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        Text("Cari acara badminton, futsal...")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(12)
                    .glassEffect()
                }
                .buttonStyle(.plain)
                
                SportFilterView(selectedSports: $selectedSports)
                    .frame(minHeight: 60)
                
                Text("Popular Activity")
                    .font(.headline)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        if filteredEvents.isEmpty {
                            ContentUnavailableView(
                                "Tidak Ada Event",
                                systemImage: "sportscourt",
                                description: Text("Belum ada aktivitas olahraga ini untuk saat ini.")
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(filteredEvents) { event in
                                NavigationLink(
                                    destination: EventDetailView(
                                        event: event,
                                        currentUserID: Auth.auth().currentUser?.uid
                                    )
                                ) {
                                    CloudEventCardView(event: event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(20)
            .background(.base)
            .navigationDestination(isPresented: $showSearch) {
                SearchResultView()
            }
        }
        .onAppear {
            // Fetch profile setiap kali Home muncul
            if let uid = Auth.auth().currentUser?.uid {
                Task {
                    await userManager.fetchProfile(uid: uid)
                }
            }
            
            // Firestore listener
            self.listenerRegistration?.remove()
            let db = Firestore.firestore()
            self.listenerRegistration = db.collection("events")
                .order(by: "date", descending: false)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = querySnapshot?.documents else { return }
                    self.listEvent = documents.compactMap { try? $0.data(as: CloudEvent.self) }
                }
        }
        .onDisappear {
            self.listenerRegistration?.remove()
        }
    }
}

#Preview {
    homeView()
}
