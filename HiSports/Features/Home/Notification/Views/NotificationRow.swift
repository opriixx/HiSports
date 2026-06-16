//
//  NotificationRow.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 15/06/26.
//

import SwiftUI

struct NotificationRow: View {

    let item: NotificationItem

    var body: some View {

        HStack {

            Image(
                systemName:
                    item.type.details.icon
            )

            VStack(
                alignment: .leading
            ) {

                Text(item.title)
                    .fontWeight(
                        item.isRead
                        ? .regular
                        : .bold
                    )

                Text(item.message)
                    .foregroundStyle(
                        .secondary
                    )
            }

            Spacer()

            if !item.isRead {

                Circle()
                    .frame(
                        width: 8,
                        height: 8
                    )
            }
        }
        .padding()
    }
}
