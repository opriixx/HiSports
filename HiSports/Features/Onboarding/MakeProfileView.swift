//
//  MakeProfileView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import SwiftUI
import FirebaseAuth

struct MakeProfileView: View {
    var authViewModel: AuthViewModel? = nil
    
    @State private var name = ""
    @State private var favSports = ""
    @State private var skillLevel: SkillLevel = .beginner
    @State private var selectedAvatar = "avatar1"
    @State private var showAvatarPicker = false
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    private let sports = Sport.defaultSports
    private let avatarOptions = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6"]
    private var isEditMode: Bool { authViewModel == nil }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Avatar
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(selectedAvatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.redBlood, lineWidth: 3))
                            
                            Button {
                                showAvatarPicker = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.redBlood)
                                    .background(Circle().fill(Color.white))
                            }
                        }
                        
                        Text("Tap untuk ganti avatar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Nama
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nama").font(.footnote).fontWeight(.semibold)
                        TextField("Masukkan nama kamu", text: $name)
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    }
                    
                    // Skill Level
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Skill Level").font(.footnote).fontWeight(.semibold)
                        Picker("Skill Level", selection: $skillLevel) {
                            ForEach(SkillLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Fav Sports
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Olahraga Favorit").font(.footnote).fontWeight(.semibold)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(sports) { sport in
                                Button {
                                    favSports = sport.name
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(sport.emoji).font(.title2)
                                        Text(sport.name).font(.caption2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(favSports == sport.name ? Color.redBlood.opacity(0.15) : Color(.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(favSports == sport.name ? Color.redBlood : Color.clear, lineWidth: 1.5)
                                    )
                                    .cornerRadius(10)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    // Tombol Save
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(isEditMode ? "Simpan Perubahan" : "Simpan Profil").fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(name.isEmpty || favSports.isEmpty ? Color.gray.opacity(0.5) : Color.redBlood)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading || name.isEmpty || favSports.isEmpty)
                    
                    if name.isEmpty || favSports.isEmpty {
                        Text("Lengkapi nama dan olahraga favorit dulu ya!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
            }
            .navigationTitle(isEditMode ? "Edit Profil" : "Buat Profil")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Pre-fill data saat view muncul
        .onAppear {
            if let profile = UserManager.shared.profile {
                name = profile.name
                favSports = profile.favSports
                skillLevel = SkillLevel(rawValue: profile.skillLevel) ?? .beginner
                selectedAvatar = profile.avatar
            }
        }
        // Sheet pilihan avatar
        .sheet(isPresented: $showAvatarPicker) {
            VStack(spacing: 20) {
                Text("Pilih Avatar")
                    .font(.headline)
                    .padding(.top, 24)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(avatarOptions, id: \.self) { avatar in
                        Button {
                            selectedAvatar = avatar
                            showAvatarPicker = false
                        } label: {
                            Image(avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(
                                        selectedAvatar == avatar ? Color.redBlood : Color.gray.opacity(0.3),
                                        lineWidth: selectedAvatar == avatar ? 3 : 1
                                    )
                                )
                                .shadow(color: selectedAvatar == avatar ? Color.redBlood.opacity(0.3) : .clear, radius: 6)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .presentationDetents([.medium])
        }
    }
    
    private func saveProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            let profile = UserProfile(
                uid: uid,
                name: name,
                favSports: favSports,
                skillLevel: skillLevel.rawValue,
                avatar: selectedAvatar
            )
            try await UserManager.shared.saveProfile(profile)
            
            if isEditMode {
                // Mode edit → dismiss sheet
                await MainActor.run { dismiss() }
            } else {
                // Mode buat baru → refresh auth → pindah ke ContentView
                await authViewModel?.refreshProfile()
            }
        } catch {
            print("Gagal simpan profil: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

#Preview {
    MakeProfileView()
}
