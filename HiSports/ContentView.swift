//
//  ContentView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 10/06/26.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    var body: some View {
        TabView {
            homeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // 🌟 Ikon diubah jadi figure.run biar gak kembar sama Profile
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "figure.run")
                }

            profileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            
        }
        // 🌟 FORCE LOGOUT SEKALI SAAT APPS DIJALANKAN
        .onAppear {
        }
    }
}

#Preview {
    ContentView()
}
