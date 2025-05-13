import SwiftUI

// View for searching and sending friend requests by email
struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: FriendsViewModel

    @State private var emailQuery = ""
    @State private var results: [AppUser] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                // Search section for friend requests
                Section(header: Text("Search by Email")) {
                    TextField("friend@example.com", text: $emailQuery)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Button("Search") {
                        performSearch()
                    }
                    .disabled(emailQuery.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                if isSearching {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                
                // Show error message if search fails
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                // Search results
                Section(header: Text("Results")) {
                    if results.isEmpty {
                        Text("No users found")
                            .foregroundColor(.secondary)
                    }
                    ForEach(results) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.displayName)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Add") {
                                vm.sendRequest(to: user.id)
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .navigationTitle("Add Friend")
            .toolbar {
                Button("Close") { dismiss() }
            }
        }
    }
    
    // Run the Firestore query to search by email
    private func performSearch() {
        let queryEmail = emailQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        print("Searching for user with email exactly: '\(queryEmail)'")

        // Reset state
        isSearching = true
        results = []
        errorMessage = nil

        // Run the Firestore query
        vm.db.collection("users")
          .whereField("email", isEqualTo: queryEmail)
          .getDocuments { snapshot, error in
            isSearching = false

            if let error = error {
                errorMessage = "Search failed: \(error.localizedDescription)"
                print("Firestore error: \(error.localizedDescription)")
                return
            }

            let docs = snapshot?.documents ?? []
            print("Firestore returned \(docs.count) document(s)")

            // Map the results
            results = docs.compactMap { doc in
                print("docID:", doc.documentID, "data:", doc.data())
                guard let email = doc.data()["email"] as? String else { return nil }
                return AppUser(id: doc.documentID,
                               displayName: email,
                               email: email)
            }

            if results.isEmpty {
                errorMessage = "No users found with that email."
            }
        }
    }
}

