//
//  EventDetailView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 11/06/26.
//

import SwiftUI
import FirebaseFirestore

struct EventDetailView: View {
    @State private var viewModel: EventDetailViewModel

    let size: CGFloat = 40

    init(event: CloudEvent, currentUserID: String?) {
        _viewModel = State(initialValue: EventDetailViewModel(event: event, currentUserID: currentUserID))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerImage

                VStack(spacing: 16) {
                    eventInfoCard
                    whosPlayingCard

                    if !viewModel.event.aboutGame.isEmpty {
                        aboutGameCard
                    }

                    gameDetailsCard
                    equipmentCard

                    if !viewModel.event.notes.isEmpty {
                        notesCard
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color("Base"))
            .ignoresSafeArea(edges: .top)
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                actionButton
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(Color("Base").ignoresSafeArea(edges: .bottom))
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            Task { await viewModel.fetchParticipantProfiles() }
        }
    }

    private var headerImage: some View {
        Group {
            if let name = viewModel.event.imageName {
                Image(name)
                    .resizable()
                    .scaledToFit()
            } else {
                ZStack {
                    Color.redBlood.opacity(0.1)
                    Text(viewModel.sportEmoji(for: viewModel.event.sport))
                        .font(.system(size: 80))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
            }
        }
    }

    private var eventInfoCard: some View {
        VStack(spacing: 12) {
            Text(viewModel.event.title)
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.formattedPrice)
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20))
                    .foregroundColor(.redBlood)
                    .padding(12)
                    .background(Circle().fill(Color("Base")))
                VStack(alignment: .leading) {
                    Text(viewModel.formattedDate)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(viewModel.formattedTime)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                Image(systemName: "map")
                    .font(.system(size: 20))
                    .foregroundColor(.redBlood)
                    .padding(12)
                    .background(Circle().fill(Color("Base")))
                VStack(alignment: .leading) {
                    Text(viewModel.event.location)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color("White-500"))
        .cornerRadius(16)
    }

    private var whosPlayingCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Who's Playing?")
                    .font(.callout)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.currentParticipantsCount) / \(viewModel.event.maxParticipants)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Peserta yang sudah join
                    ForEach(viewModel.event.participants, id: \.self) { uid in
                        VStack(spacing: 4) {
                            if let profile = viewModel.participantProfiles[uid] {
                                Image(profile.avatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size, height: size)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                Text(profile.name.isEmpty ? "User" : profile.name)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .frame(width: size + 10)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: size, height: size)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                }
                                Text("User")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: size + 10)
                            }
                        }
                    }

                    // Slot kosong
                    ForEach(0..<max(0, viewModel.remainingSlots), id: \.self) { _ in
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                                    )
                                    .foregroundColor(Color.redBlood.opacity(0.4))
                                    .frame(width: size, height: size)
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.redBlood.opacity(0.6))
                            }
                            Text("Slot")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: size + 10)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color("White-500"))
        .cornerRadius(16)
    }

    private var aboutGameCard: some View {
        VStack(spacing: 12) {
            Text("About This Game")
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.event.aboutGame)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color("White-500"))
        .cornerRadius(16)
    }

    private var gameDetailsCard: some View {
        VStack(spacing: 0) {
            Text("Game Details")
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)

            detailRow(label: "Duration", value: viewModel.duration)
            detailRow(label: "Skill Level", value: viewModel.event.skillLevel)
            detailRow(label: "Dresscode", value: viewModel.event.dressCode, isLast: true)
        }
        .padding(12)
        .background(Color("White-500"))
        .cornerRadius(16)
    }

    private var equipmentCard: some View {
        let allEquipment = Sport.defaultSports
            .first { $0.name == viewModel.event.sport }?
            .availableEquipments ?? []

        return VStack(spacing: 0) {
            Text("Equipment")
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)

            if allEquipment.isEmpty {
                Text("No equipment info")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(allEquipment.enumerated()), id: \.offset) { index, item in
                    let isProvided = viewModel.event.equipment.contains(item)
                    detailRow(
                        label: item,
                        value: isProvided ? "Provided ✓" : "Bring your own",
                        valueColor: isProvided ? .green : .secondary,
                        isLast: index == allEquipment.count - 1
                    )
                }
            }
        }
        .padding(12)
        .background(Color("White-500"))
        .cornerRadius(16)
    }

    private var notesCard: some View {
        VStack(spacing: 12) {
            Text("Notes")
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.event.notes)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color("White-500"))
        .cornerRadius(16)
    }

    @ViewBuilder
    private var actionButton: some View {
        if viewModel.isCreator {
            NavigationLink(destination: EditEventView(event: viewModel.event)) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Event").fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.redBlood)
                .foregroundColor(.white)
                .cornerRadius(14)
            }
        } else if viewModel.isParticipant {
            Button(action: { viewModel.leaveEvent() }) {
                HStack {
                    Image(systemName: "person.fill.xmark")
                    Text("Leave Event").fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(14)
            }
        } else if viewModel.isFull {
            HStack {
                Image(systemName: "person.fill.questionmark")
                Text("Event Full").fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.15))
            .foregroundColor(.secondary)
            .cornerRadius(14)
        } else {
            Button(action: { viewModel.joinEvent() }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Join Event").fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.redBlood)
                .foregroundColor(.white)
                .cornerRadius(14)
            }
        }
    }

    private func detailRow(
        label: String,
        value: String,
        valueColor: Color = .primary,
        isLast: Bool = false
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(label)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(value)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(valueColor)
            }
            .padding(.vertical, 12)

            if !isLast {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 0.5)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView(
            event: CloudEvent(
                id: "preview_id",
                title: "Jakarta Basketball Cloud",
                sport: "Basketball",
                location: "Agora Sports Hall",
                date: Date(),
                endTime: Date().addingTimeInterval(7200),
                price: 50000,
                maxParticipants: 5,
                skillLevel: "Intermediate",
                equipment: ["Ball"],
                dressCode: "Sportswear",
                notes: "Catatan dummy cloud",
                aboutGame: "Main seru-seruan bareng anak-anak",
                imageName: nil,
                creatorId: "dummy_user_id",
                participants: ["dummy_user_id"]
            ),
            currentUserID: "dummy_user_id"
        )
    }
}
