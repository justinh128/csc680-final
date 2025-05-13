import Foundation
import FirebaseAuth

// ViewModel for handling the user's saved capsules
class SavedCapsulesViewModel: ObservableObject {
    @Published var savedCapsules: [Capsule] = []

    // Fetch all saved capsules for the current user
    func fetchSavedCapsules() {
        // Make sure a user is logged in
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        // Use the shared database service to get saved capsules
        DatabaseService.shared.fetchSavedCapsules(for: uid) { capsules, error in
            if let capsules = capsules {
                DispatchQueue.main.async {
                    self.savedCapsules = capsules
                }
            } else if let error = error {
                print("Error fetching saved capsules: \(error.localizedDescription)")
            }
        }
    }
}
