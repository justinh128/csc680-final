import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignup = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Capsule")
                .font(.largeTitle)
                .bold()

            // Email input
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Password input
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Show error if login fails
            if let error = authViewModel.authError {
                Text(error)
                    .foregroundColor(.red)
            }

            // Login button
            Button("Login") {
                authViewModel.login(email: email, password: password)
            }
            .buttonStyle(.borderedProminent)

            // Show signup screen
            Button("Don't have an account? Sign up") {
                isShowingSignup = true
            }
            .font(.footnote)
        }
        .padding()
        .sheet(isPresented: $isShowingSignup) {
            SignupView()
                .environmentObject(authViewModel)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
