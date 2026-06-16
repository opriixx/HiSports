//
//  MakeProfileView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct MakeProfileView: View {
    @State private var name = ""
    @State private var favSports = ""
    @State private var skillLevel: SkillLevel = .beginner
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    private let sports = Sport.defaultSports
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Foto Profile
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 100, height: 100)
                                    Image(systemName: "camera.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .onChange(of: selectedPhoto) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image
                                }
                            }
                        }
                        
                        Text("Tap untuk pilih foto")
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
                                Text("Simpan Profil").fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.redBlood)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading)
                    
                    // Skip
                    Button("Lewati untuk sekarang") {
                        dismiss()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                .padding(24)
            }
            .navigationTitle("Buat Profil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            var photoURL: String? = nil
            if let image = selectedImage {
                photoURL = try await UserManager.shared.uploadPhoto(uid: uid, image: image)
            }
            
            let profile = UserProfile(
                uid: uid,
                name: name,
                favSports: favSports,
                skillLevel: skillLevel.rawValue,
                photoURL: photoURL
            )
            
            try await UserManager.shared.saveProfile(profile)
            dismiss()
        } catch {
            print("Gagal simpan profil: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

#Preview {
    MakeProfileView()
}
