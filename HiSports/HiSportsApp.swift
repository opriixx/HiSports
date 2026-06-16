//
//  HiSportsApp.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 10/06/26.
//

//
//  HiSportsApp.swift
//  HiSports
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct HiSportsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authViewModel: AuthViewModel? = nil

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let vm = authViewModel {
                    if vm.user != nil {
                        ContentView()
                    } else {
                        NavigationStack { LoginView() }
                    }
                } else {
                    ProgressView()
                }
            }
            .task {
                self.authViewModel = AuthViewModel()
            }
        }
    }
}
