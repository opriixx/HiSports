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

                    if !viewModel.event.equipment.isEmpty {
                        equipmentCard
                    }

                    if !viewModel.event.notes.isEmpty {
                        notesCard
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color("Base"))
            .ignoresSafeArea(edges: .top)
        }
        .overlay(alignment: .bottom) {
            actionButton
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
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

            HStack(spacing: -15) {
                ForEach(viewModel.event.participants, id: \.self) { participantId in
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .background(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .background(Circle().fill(Color("Base")))
                        )
                        .frame(width: size, height: size)
                }

                if viewModel.remainingSlots > 0 {
                    ZStack {
                        Circle()
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2.5, dash: [8, 5])
                            )
                            .foregroundColor(Color(red: 0.9, green: 0.5, blue: 0.55).opacity(0.7))
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.65, green: 0.1, blue: 0.15))
                    }
                    .frame(width: size, height: size)

                    if viewModel.remainingSlots > 1 {
                        Text("+\(viewModel.remainingSlots - 1) slot")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        VStack(spacing: 0) {
            Text("Equipment")
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)

            ForEach(Array(viewModel.event.equipment.enumerated()), id: \.offset) { index, item in
                detailRow(
                    label: item,
                    value: "Provided",
                    valueColor: .green,
                    isLast: index == viewModel.event.equipment.count - 1
                )
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
                maxParticipants: 15,
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
