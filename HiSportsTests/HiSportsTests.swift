//
//  HiSportsTests.swift
//  HiSportsTests
//
//  Created by Muhammad Ridwan Novriansyah on 10/06/26.
//

import Foundation
import Testing
@testable import HiSports

struct HiSportsTests {

    @Test func sportDefaultDataContainsExpectedSports() {
        let sports = Sport.defaultSports
        let sportNames = sports.map(\.name)

        #expect(sports.count == 6)
        #expect(sportNames == ["Badminton", "Basketball", "Football", "Tennis", "Volleyball", "Mini Soccer"])
        #expect(sports.allSatisfy { !$0.availableEquipments.isEmpty })
    }

    @Test func skillLevelAndDressCodeRawValuesMatchDisplayText() {
        #expect(SkillLevel.allCases.map(\.rawValue) == ["Beginner", "Intermediate", "Expert"])
        #expect(DressCode.allCases.map(\.rawValue) == ["Casual", "Jersey", "Sportswear", "Formal"])
    }

    @Test func createEventStartsWithRequiredFieldsEmpty() {
        let viewModel = CreateEventViewModel()

        #expect(viewModel.title.isEmpty)
        #expect(viewModel.sport.isEmpty)
        #expect(viewModel.location.isEmpty)
        #expect(viewModel.price == 0)
        #expect(viewModel.maxParticipants == 2)
        #expect(viewModel.skillLevel == .beginner)
        #expect(viewModel.dresscode == .casual)
        #expect(viewModel.isSaveDisabled)
    }

    @Test func createEventSaveButtonEnablesWhenRequiredFieldsAreFilled() {
        let viewModel = CreateEventViewModel()

        viewModel.title = "Morning Badminton"
        viewModel.sport = "Badminton"
        viewModel.location = "GOR Senayan"

        #expect(!viewModel.isSaveDisabled)
    }

    @Test func changingSportClearsSelectedEquipment() {
        let viewModel = CreateEventViewModel()

        viewModel.sport = "Badminton"
        viewModel.equipment = ["Net", "Racket"]
        viewModel.sport = "Tennis"

        #expect(viewModel.equipment.isEmpty)
    }

    @Test func textFieldsAreTrimmedToTheirCharacterLimits() {
        let viewModel = CreateEventViewModel()

        viewModel.notes = String(repeating: "A", count: viewModel.notesCharacterLimit + 25)
        viewModel.aboutGame = String(repeating: "B", count: viewModel.aboutGameCharacterLimit + 25)

        #expect(viewModel.notes.count == viewModel.notesCharacterLimit)
        #expect(viewModel.aboutGame.count == viewModel.aboutGameCharacterLimit)
    }

    @Test func selectedSportDataAndImageFollowSelectedSport() {
        let viewModel = CreateEventViewModel()

        viewModel.sport = "Basketball"

        #expect(viewModel.selectedSportData?.name == "Basketball")
        #expect(viewModel.selectedSportImageName == "Basketball")
    }

    @Test func cloudEventCountsParticipants() {
        let event = makeEvent(participants: ["user-1", "user-2", "user-3"])

        #expect(event.currentParticipantsCount == 3)
    }

    @Test func eventDetailViewModelIdentifiesCreatorParticipantAndFullEvent() {
        let event = makeEvent(maxParticipants: 2, creatorId: "creator-id", participants: ["creator-id", "user-2"])
        let creatorViewModel = EventDetailViewModel(event: event, currentUserID: "creator-id")
        let participantViewModel = EventDetailViewModel(event: event, currentUserID: "user-2")
        let guestViewModel = EventDetailViewModel(event: event, currentUserID: nil)

        #expect(creatorViewModel.isCreator)
        #expect(creatorViewModel.isParticipant)
        #expect(participantViewModel.isParticipant)
        #expect(!guestViewModel.isCreator)
        #expect(!guestViewModel.isParticipant)
        #expect(creatorViewModel.isFull)
        #expect(creatorViewModel.remainingSlots == 0)
    }

    @Test func eventDetailViewModelFormatsDuration() {
        let startDate = makeDate(year: 2026, month: 6, day: 20, hour: 7, minute: 15)
        let endDate = makeDate(year: 2026, month: 6, day: 20, hour: 8, minute: 45)
        let event = makeEvent(date: startDate, endTime: endDate)
        let viewModel = EventDetailViewModel(event: event)

        #expect(viewModel.duration == "1 Hour 30 Minutes")
    }

    @Test func sportEmojiReturnsMatchingEmojiOrFallback() {
        let viewModel = EventDetailViewModel(event: makeEvent())

        #expect(viewModel.sportEmoji(for: "Badminton") == "🏸")
        #expect(viewModel.sportEmoji(for: "Unknown Sport") == "🏅")
    }

    private func makeEvent(
        title: String = "Morning Badminton",
        sport: String = "Badminton",
        location: String = "GOR Senayan",
        date: Date? = nil,
        endTime: Date? = nil,
        price: Int = 50000,
        maxParticipants: Int = 4,
        skillLevel: String = SkillLevel.beginner.rawValue,
        equipment: [String] = ["Net", "Racket"],
        dressCode: String = DressCode.casual.rawValue,
        notes: String = "Bring your own bottle.",
        aboutGame: String = "Friendly match.",
        imageName: String? = "badminton",
        creatorId: String = "creator-id",
        participants: [String] = []
    ) -> CloudEvent {
        let eventDate = date ?? makeDate(year: 2026, month: 6, day: 20, hour: 7, minute: 0)
        let eventEndTime = endTime ?? makeDate(year: 2026, month: 6, day: 20, hour: 8, minute: 0)

        return CloudEvent(
            title: title,
            sport: sport,
            location: location,
            date: eventDate,
            endTime: eventEndTime,
            price: price,
            maxParticipants: maxParticipants,
            skillLevel: skillLevel,
            equipment: equipment,
            dressCode: dressCode,
            notes: notes,
            aboutGame: aboutGame,
            imageName: imageName,
            creatorId: creatorId,
            participants: participants
        )
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        return calendar.date(from: DateComponents(
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        ))!
    }
}
