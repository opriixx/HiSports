//
//  LoginView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 16/06/26.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo
            Image("HiSportsLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
            
            VStack(spacing: 16) {
                // Email Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.footnote).fontWeight(.semibold)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.gray, lineWidth: 0.5))
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.footnote).fontWeight(.semibold)
                    SecureField("Password", text: $password)
                        .padding(12)
                        .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.gray, lineWidth: 0.5))
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption).foregroundColor(.red)
                }
                
                // Login Button
                Button(action: {
                    Task { await loginUser() }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login").fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(email.isEmpty || password.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                
                // Link ke Register
                NavigationLink("Belum punya akun? Daftar di sini", destination: registerView())
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(24)
    }
    
    private func loginUser() async {
        isLoading = true
        errorMessage = ""
        
        do {
            _ = try await AuthManager.shared.signIn(email: email, password: password)
            // Gak perlu navigasi manual! AuthViewModel di App akan otomatis ganti ke ContentView
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
