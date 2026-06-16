//
//  CreateEventViewModel.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 11/06/26.
//

import Foundation

@Observable
class CreateEventViewModel {
    let listSport = Sport.defaultSports
    let notesCharacterLimit = 1000
    let aboutGameCharacterLimit = 500
    var title: String = ""
    var sport: String = "" {
        didSet {
            equipment = []
        }
    }
    var location: String = ""
    var date: Date = Date()
    var endTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    var price: Int = 0
    var maxParticipants: Int = 2
    var skillLevel: SkillLevel = .beginner
    var equipment: [String] = []
    var dresscode: DressCode = .casual
    var isLoading: Bool = false
    var aboutGame: String = "" {
        didSet {
            if aboutGame.count > aboutGameCharacterLimit {
                aboutGame = String(aboutGame.prefix(aboutGameCharacterLimit))
            }
        }
    }
    
    var notes: String = "" {
        didSet {
            if notes.count > notesCharacterLimit {
                notes = String(notes.prefix(notesCharacterLimit))
            }
        }
    }

    var selectedSportData: Sport? {
        listSport.first(where: { $0.name == sport })
    }
    
    var selectedSportImageName: String? {
        selectedSportData?.imageName
    }
    
    var isSaveDisabled: Bool {
        isLoading || title.isEmpty || sport.isEmpty || location.isEmpty
    }

    func actionSaveEvent() async -> Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard !sport.isEmpty else { return false }
        guard !location.isEmpty else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await EventManager.shared.createEvent(
                title: title,
                sport: sport,
                location: location,
                date: date,
                endTime: endTime,
                price: price,
                maxParticipants: maxParticipants,
                skillLevel: skillLevel,
                equipment: equipment,
                dressCode: dresscode,
                notes: notes,
                aboutGame: aboutGame,
                imageName: selectedSportImageName
            )
            
            NotificationManager.shared.sendCreateEventNotification(eventName: title)
            return true
        } catch {
            print("Gagal menyimpan ke cloud: \(error.localizedDescription)")
            return false
        }
    }
}
