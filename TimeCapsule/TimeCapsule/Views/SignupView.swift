import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title)

            // Email input
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Password input
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Show error if signup fails
            if let error = authViewModel.authError {
                Text(error)
                    .foregroundColor(.red)
            }

            // Sign up button
            Button("Sign Up") {
                authViewModel.signup(email: email, password: password)
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)

            // Cancel button
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.footnote)
        }
        .padding()
    }
}
