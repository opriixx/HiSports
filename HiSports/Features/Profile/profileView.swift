//
//  profileView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 10/06/26.
//

import SwiftUI
import FirebaseAuth

struct profileView: View {
    @State private var userManager = UserManager.shared
    @State private var showMakeProfile = false
    
    private var profile: UserProfile? { userManager.profile }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        Image(profile?.avatar ?? "avatar1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.redBlood.opacity(0.3), lineWidth: 2))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile?.name.isEmpty == false ? "Hi, \(profile!.name)!" : "Hi, Athlete!")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(profile?.skillLevel ?? "-")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Stats Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Stats")
                            .font(.headline)
                        
                        HStack(spacing: 0) {
                            statItem(label: "Total Matches", value: "\(profile?.totalMatches ?? 0)")
                            Divider().frame(height: 40)
                            statItem(label: "Skill Level", value: profile?.skillLevel ?? "-")
                            Divider().frame(height: 40)
                            statItem(label: "Fav Sports", value: profile?.favSports.isEmpty == false ? profile!.favSports : "-")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            settingRow(title: "Edit Profil", icon: "person.fill") {
                                showMakeProfile = true
                            }
                            Divider().padding(.leading)
                            settingRow(title: "Logout", icon: "rectangle.portrait.and.arrow.right", color: .red) {
                                userManager.clearProfile()
                                try? Auth.auth().signOut()
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showMakeProfile) {
            MakeProfileView()
        }
        .onAppear {
            if let uid = Auth.auth().currentUser?.uid {
                Task {
                    await userManager.fetchProfile(uid: uid)
                    await userManager.updateTotalMatches(uid: uid)
                }
            }
        }
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func settingRow(title: String, icon: String, color: Color = .primary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                Text(title)
                    .foregroundColor(color)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
