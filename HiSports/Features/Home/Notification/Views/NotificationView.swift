//
//  NotificationView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 14/06/26.
//

//
//  NotificationView.swift
//  HiSports
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    private var manager = NotificationManager.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
                Text("Notifications")
                    .font(.headline)
                Spacer()
                if !manager.notifications.isEmpty {
                    Button("Tandai Semua") {
                        manager.notifications.forEach { $0.isRead = true }
                    }
                    .font(.caption)
                }
            }
            .padding()

            if manager.notifications.isEmpty {
                ContentUnavailableView(
                    "No Notifications",
                    systemImage: "bell.slash",
                    description: Text("You're all caught up!")
                )
            } else {
                List {
                    ForEach(manager.notifications) { item in
                        NotificationRow(item: item)
                            .onTapGesture { item.isRead = true }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    manager.notifications.removeAll { $0.id == item.id }
                                } label: {
                                    Label("Hapus", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    NotificationView()
}
