//
//  CreateEventView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 11/06/26.
//

import SwiftUI
import MapKit

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CreateEventViewModel()
    @State private var showingLocationPicker = false

    var body: some View {
        Form {
            Section(header: Text("Detail Event")) {
                TextField("Nama Event", text: $viewModel.title)

                Button(action: { showingLocationPicker = true }) {
                    HStack {
                        Text("Location").foregroundColor(.primary)
                        Spacer()
                        Text(viewModel.location.isEmpty ? "Pilih Lokasi..." : viewModel.location)
                            .foregroundColor(viewModel.location.isEmpty ? .gray : .redBlood)
                            .lineLimit(1)
                    }
                }

                Picker("Kategori Olahraga", selection: $viewModel.sport) {
                    Text("Pilih olahraga").tag("")
                    ForEach(viewModel.listSport) { sport in
                        Text("\(sport.emoji) \(sport.name)").tag(sport.name)
                    }
                }
            }
            
            Section(header: Text("Price/pax")){
                TextField("Price", value: $viewModel.price, format: .currency(code: "IDR"))
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Schedule & Time")) {
                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                DatePicker("Starts", selection: $viewModel.date, displayedComponents: [.hourAndMinute])
                DatePicker("End", selection: $viewModel.endTime, displayedComponents: [.hourAndMinute])
            }

            Section(header: Text("Participation")) {
                Stepper(
                    "Maksimal Peserta: \(viewModel.maxParticipants)",
                    value: $viewModel.maxParticipants,
                    in: 2...50
                )
            }

            Section(header: Text("Skill Level")) {
                Picker("Label", selection: $viewModel.skillLevel) {
                    ForEach(SkillLevel.allCases, id: \.self) { lvl in
                        Text(lvl.rawValue).tag(lvl)
                    }
                }
                .pickerStyle(.segmented)
            }

            if let sportData = viewModel.selectedSportData {
                Section(header: Text("Equipment (\(sportData.name))")) {
                    ForEach(sportData.availableEquipments, id: \.self) { item in
                        let isProvided = viewModel.equipment.contains(item)
                        Toggle(isOn: Binding(
                            get: { isProvided },
                            set: { newValue in
                                if newValue {
                                    viewModel.equipment.append(item)
                                } else {
                                    viewModel.equipment.removeAll { $0 == item }
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
            } else {
                Section(header: Text("Equipment")) {
                    Text("Please, choose your sports category first")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }

            Section(header: Text("Dresscode")) {
                Picker("Dresscode", selection: $viewModel.dresscode) {
                    ForEach(DressCode.allCases, id: \.self) { dc in
                        Text(dc.rawValue).tag(dc)
                    }
                }
            }

            Section(header: Text("About This Game")) {
                VStack(alignment: .trailing, spacing: 4) {
                    TextField(
                        "Describe your event, rules, vibes, etc...",
                        text: $viewModel.aboutGame,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                    Text("\(viewModel.aboutGame.count) / \(viewModel.aboutGameCharacterLimit)")
                        .font(.caption)
                        .foregroundColor(
                            viewModel.aboutGame.count >= viewModel.aboutGameCharacterLimit ? .red : .gray
                        )
                        .padding(.horizontal)
                }
            }

            Section(header: Text("Notes")) {
                VStack(alignment: .trailing) {
                    TextField("Write the notes...", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)

                    Text("\(viewModel.notes.count) / \(viewModel.notesCharacterLimit)")
                        .font(.caption)
                        .foregroundColor(
                            viewModel.notes.count >= viewModel.notesCharacterLimit ? .red : .gray
                        )
                        .padding(.horizontal)
                }
            }

            Button(action: {
                Task {
                    let isSuccess = await viewModel.actionSaveEvent()
                    if isSuccess {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save").fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding()
                .background(viewModel.isSaveDisabled ? Color(.systemGray4) : Color.red)
            }
            .disabled(viewModel.isSaveDisabled)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
        }
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(selectedLocationName: $viewModel.location)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    CreateEventView()
}
