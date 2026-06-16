//
//  registerView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 10/06/26.
//

import SwiftUI

struct registerView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showMakeProfile = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("HiSportsLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    SecureField("Password", text: $password)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Confirm Password")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                Button(action: {
                    Task { await registerUser() }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Daftar").fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(email.isEmpty || password.isEmpty || confirmPassword.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || isLoading)
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .padding(24)
        // Setelah register → MakeProfile dulu, bisa skip
        .navigationDestination(isPresented: $showMakeProfile) {
            MakeProfileView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func registerUser() async {
        guard password == confirmPassword else {
            errorMessage = "Password dan Confirm Password not match."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            _ = try await AuthManager.shared.signUp(email: email, password: password)
            print("Registration Success!")
            isLoading = false
            showMakeProfile = true  // → ke MakeProfileView
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        registerView()
    }
}
