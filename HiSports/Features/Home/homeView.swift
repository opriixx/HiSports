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
    
    // 🌟 Ganti @Query SwiftData dengan State Array khusus CloudEvent
    @State private var listEvent: [CloudEvent] = []
    @State private var listenerRegistration: ListenerRegistration? = nil

    // Filter event disesuaikan dengan tipe CloudEvent
    private var filteredEvents: [CloudEvent] {
        guard !selectedSports.isEmpty else { return listEvent }
        return listEvent.filter { event in
            selectedSports.contains(event.sport)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hello, User!")
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

                NavigationLink {
                    CreateEventView()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                        Text("Add Event")
                        Spacer()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.red, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
            .navigationDestination(isPresented: $showSearch) {
                SearchResultView()
            }
        }
        // 🌟 BAGIAN PENTING: Koneksi Real-time ke Firebase Firestore
        .onAppear {
            // Bersihkan listener lama biar gak terjadi memory leak
            self.listenerRegistration?.remove()
            
            // Dengerin data collection 'events' dari server Firestore secara live
            let db = Firestore.firestore()
            self.listenerRegistration = db.collection("events")
                .order(by: "date", descending: false) // Urutkan berdasarkan tanggal terdekat
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("Error nembak data Firestore: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("Dokumen kosong")
                        return
                    }
                    
                    // Mapping data dari JSON Firestore ke Model CloudEvent Swift
                    self.listEvent = documents.compactMap { doc -> CloudEvent? in
                        try? doc.data(as: CloudEvent.self)
                    }
                }
        }
        // Matiin satpam listener pas pindah page demi menghemat kuota Firebase
        .onDisappear {
            self.listenerRegistration?.remove()
        }
    }
}

#Preview {
    homeView()
}
