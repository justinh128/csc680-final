import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseFirestore

// Handles user login, signup, and auth state
class AuthViewModel: ObservableObject {
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var isLoggedIn = false
    @Published var authError: String?

    init() {
        listenToAuthState()
    }

    // Automatically updates when user logs in/out
    private func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.firebaseUser = user
            self.isLoggedIn = (user != nil)
        }
    }

    // Try to log in with email and password
    func login(email: String, password: String) {
        authError = nil
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.authError = error.localizedDescription
            }
            // on success, the state listener will update firebaseUser/isLoggedIn
        }
    }

    // Create a new account and save user email to Firestore
    func signup(email: String, password: String) {
        authError = nil
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.authError = error.localizedDescription
                return
            }
            guard let user = result?.user else { return }

            // Write a Firestore document under "users/{uid}" with just the email
            let db = Firestore.firestore()
            db.collection("users")
              .document(user.uid)
              .setData(["email": user.email ?? ""]) { error in
                  if let error = error {
                      print("Failed to create user doc:", error.localizedDescription)
                  } else {
                      print("Created user doc for \(user.email ?? "")")
                  }
              }
        }
    }
    
    // Sign out and clear local state
    func logout() {
        try? Auth.auth().signOut()
        self.firebaseUser = nil
        self.isLoggedIn = false
    }
}


