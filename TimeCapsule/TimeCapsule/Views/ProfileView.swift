import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Show email if signed in, otherwise prompt to log in
            if let email = authViewModel.firebaseUser?.email {
                Text("Email: \(email)")
                    .font(.subheadline)
            } else {
                Text("Not logged in")
                    .font(.subheadline)
            }

            // Logout button only if logged in
            if authViewModel.isLoggedIn {
                Button("Log out") {
                    authViewModel.logout()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("Profile")
    }
}
