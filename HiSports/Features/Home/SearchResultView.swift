//
//  SearchResultView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 11/06/26.
//

import SwiftUI
import FirebaseFirestore

struct SearchResultView: View {
    @State private var allEvents: [CloudEvent] = []
    @State private var listenerRegistration: ListenerRegistration?
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var filteredEvents: [CloudEvent] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        return allEvents.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.sport.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Cari acara badminton, futsal...", text: $searchText)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .focused($isSearchFocused)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .glassEffect()

                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search Event",
                        systemImage: "magnifyingglass",
                        description: Text("Type the name of event")
                    )
                } else if filteredEvents.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("No events found for \"\(searchText)\"")
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEvents) { event in
                            CloudEventCardView(event: event)
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Cari Event")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isSearchFocused = true
            let db = Firestore.firestore()
            listenerRegistration = db.collection("events")
                .order(by: "date", descending: false)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Gagal fetch events: \(error.localizedDescription)")
                        return
                    }
                    guard let docs = snapshot?.documents else { return }
                    allEvents = docs.compactMap { try? $0.data(as: CloudEvent.self) }
                }
        }
        .onDisappear {
            listenerRegistration?.remove()
        }
    }
}

#Preview {
    SearchResultView()
}
