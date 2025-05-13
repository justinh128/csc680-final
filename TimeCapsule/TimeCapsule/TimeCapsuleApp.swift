//
//  TimeCapsuleApp.swift
//  TimeCapsule
//
//  Created by Justin Ho on 2/22/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@main
struct TimeCapsuleApp: App {
    @StateObject var authViewModel    = AuthViewModel()
    @StateObject var friendsViewModel = FriendsViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(friendsViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
                    .environmentObject(friendsViewModel)
            }
        }
    }
}

