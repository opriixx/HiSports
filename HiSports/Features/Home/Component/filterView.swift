//
//  filterView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 10/06/26.
//

//
//  SportFilterView.swift
//  HiSports
//

import SwiftUI

struct SportFilterView: View {
    @Binding var selectedSports: [String]
    var selectionLimit: Int?

    private let sports = Sport.defaultSports

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(sports) { sport in
                    let isSelected = selectedSports.contains(sport.name)

                    Button {
                        toggleSelection(for: sport.name)
                    } label: {
                        if isSelected {
                            HStack(spacing: 6) {
                                Text(sport.emoji)
                                Text(sport.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.red, in: Capsule())
                        } else {
                            Text(sport.emoji)
                                .font(.title3)
                                .frame(width: 48, height: 48)
                                .background(Color(.systemBackground), in: Circle())
                                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        }
                    }
                    .animation(.spring(duration: 0.3), value: selectedSports)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func toggleSelection(for sportName: String) {
        if let index = selectedSports.firstIndex(of: sportName) {
            selectedSports.remove(at: index)
            return
        }

        if let selectionLimit, selectedSports.count >= selectionLimit {
            selectedSports.removeFirst(selectedSports.count - selectionLimit + 1)
        }
        selectedSports.append(sportName)
    }
}

#Preview {
    SportFilterView(selectedSports: .constant(["Badminton"]))
}
