//
//  EditEventView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import SwiftUI
import MapKit

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss

    let event: CloudEvent

    @State private var title: String
    @State private var sport: String
    @State private var location: String
    @State private var date: Date
    @State private var endTime: Date
    @State private var price: Int
    @State private var maxParticipants: Int
    @State private var skillLevel: SkillLevel
    @State private var equipment: [String]
    @State private var dressCode: DressCode
    @State private var notes: String
    @State private var aboutGame: String
    @State private var isLoading = false
    @State private var showingLocationPicker = false
    @State private var errorMessage: String?

    private let listSport = Sport.defaultSports
    private let notesCharacterLimit = 1000
    private let aboutGameCharacterLimit = 500

    init(event: CloudEvent) {
        self.event = event

        _title = State(initialValue: event.title)
        _sport = State(initialValue: event.sport)
        _location = State(initialValue: event.location)
        _date = State(initialValue: event.date)
        _endTime = State(initialValue: event.endTime)
        _price = State(initialValue: event.price)
        _maxParticipants = State(initialValue: event.maxParticipants)
        _skillLevel = State(initialValue: SkillLevel(rawValue: event.skillLevel) ?? .beginner)
        _equipment = State(initialValue: event.equipment)
        _dressCode = State(initialValue: DressCode(rawValue: event.dressCode) ?? .casual)
        _notes = State(initialValue: event.notes)
        _aboutGame = State(initialValue: event.aboutGame)
    }

    var body: some View {
        Form {
            Section(header: Text("Detail Event")) {
                TextField("Nama Event", text: $title)

                Button(action: { showingLocationPicker = true }) {
                    HStack {
                        Text("Location")
                            .foregroundColor(.primary)

                        Spacer()

                        Text(location.isEmpty ? "Pilih Lokasi..." : location)
                            .foregroundColor(location.isEmpty ? .gray : .redBlood)
                            .lineLimit(1)
                    }
                }

                Picker("Kategori Olahraga", selection: $sport) {
                    Text("Pilih olahraga").tag("")
                    ForEach(listSport) { sport in
                        Text("\(sport.emoji) \(sport.name)").tag(sport.name)
                    }
                }

                TextField("Price", value: $price, format: .currency(code: "IDR"))
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Schedule & Time")) {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                DatePicker("Starts", selection: $date, displayedComponents: [.hourAndMinute])
                DatePicker("End", selection: $endTime, displayedComponents: [.hourAndMinute])
            }

            Section(header: Text("Participation")) {
                Stepper(
                    "Maksimal Peserta: \(maxParticipants)",
                    value: $maxParticipants,
                    in: max(2, event.participants.count)...50
                )

                if event.participants.count > 0 {
                    Text("Current participants: \(event.participants.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(header: Text("Skill Level")) {
                Picker("Label", selection: $skillLevel) {
                    ForEach(SkillLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }

            let selectedSportData = listSport.first(where: { $0.name == sport })

            if let sportData = selectedSportData {
                Section(header: Text("Equipment (\(sportData.name))")) {
                    ForEach(sportData.availableEquipments, id: \.self) { item in
                        let isProvided = equipment.contains(item)

                        Toggle(isOn: Binding(
                            get: { equipment.contains(item) },
                            set: { newValue in
                                if newValue {
                                    if !equipment.contains(item) {
                                        equipment.append(item)
                                    }
                                } else {
                                    equipment.removeAll { $0 == item }
                                }
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Text(isProvided ? "Provided by the committee" : "Bring your own")
                                    .font(.caption)
                                    .foregroundColor(isProvided ? .green : .secondary)
                            }
                        }
                        .toggleStyle(.switch)
                        .tint(.green)
                    }
                }
                .onChange(of: sport) { oldValue, newValue in
                    if oldValue != newValue {
                        equipment = []
                    }
                }
            } else {
                Section(header: Text("Equipment")) {
                    Text("Please, choose your sports category first")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }

            Section(header: Text("Dresscode")) {
                Picker("Dresscode", selection: $dressCode) {
                    ForEach(DressCode.allCases, id: \.self) { dressCode in
                        Text(dressCode.rawValue).tag(dressCode)
                    }
                }
            }

            Section(header: Text("About This Game")) {
                VStack(alignment: .trailing, spacing: 4) {
                    TextField(
                        "Describe your event, rules, vibes, etc...",
                        text: $aboutGame,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                    .onChange(of: aboutGame) { _, newValue in
                        if newValue.count > aboutGameCharacterLimit {
                            aboutGame = String(newValue.prefix(aboutGameCharacterLimit))
                        }
                    }

                    Text("\(aboutGame.count) / \(aboutGameCharacterLimit)")
                        .font(.caption)
                        .foregroundColor(aboutGame.count >= aboutGameCharacterLimit ? .red : .gray)
                        .padding(.horizontal)
                }
            }

            Section(header: Text("Notes")) {
                VStack(alignment: .trailing) {
                    TextField("Write the notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .onChange(of: notes) { _, newValue in
                            if newValue.count > notesCharacterLimit {
                                notes = String(newValue.prefix(notesCharacterLimit))
                            }
                        }

                    Text("\(notes.count) / \(notesCharacterLimit)")
                        .font(.caption)
                        .foregroundColor(notes.count >= notesCharacterLimit ? .red : .gray)
                        .padding(.horizontal)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }

            Button(action: saveChanges) {
                HStack {
                    Spacer()

                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Save Changes")
                            .fontWeight(.bold)
                    }

                    Spacer()
                }
            }
            .disabled(isLoading || title.isEmpty || sport.isEmpty || location.isEmpty)
        }
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(selectedLocationName: $location)
                .presentationDetents([.medium, .large])
        }
    }

    private func saveChanges() {
        guard let eventId = event.id else {
            errorMessage = "Event ID tidak ditemukan."
            return
        }

        isLoading = true
        errorMessage = nil

        let updatedEvent = CloudEvent(
            id: event.id,
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
            imageName: event.imageName,
            creatorId: event.creatorId,
            participants: event.participants
        )

        Task {
            do {
                try await EventManager.shared.updateEvent(
                    eventId: eventId,
                    updatedEvent: updatedEvent
                )

                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Gagal update event: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditEventView(
            event: CloudEvent(
                id: "preview_id",
                title: "Jakarta Basketball Cloud",
                sport: "Basketball",
                location: "Agora Sports Hall",
                date: Date(),
                endTime: Date().addingTimeInterval(7200),
                price: 50000,
                maxParticipants: 15,
                skillLevel: "Intermediate",
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
}
