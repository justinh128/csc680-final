import FirebaseFirestore

// Handles all Firestore operations for capsules
class DatabaseService {
    static let shared = DatabaseService()
    private let db = Firestore.firestore()

    private init() {} // Singleton pattern

    // Save Capsule to Firestore
    func saveCapsule(_ capsule: Capsule, completion: @escaping (Error?) -> Void) {
        db.collection("capsules").document(capsule.id).setData(capsule.toDictionary()) { error in
            completion(error)
        }
    }

    // Get all capsules for a specific user
    func fetchCapsules(for userId: String, completion: @escaping ([Capsule]?, Error?) -> Void) {
        db.collection("capsules")
            .whereField("userId", isEqualTo: userId) // Filter by logged-in user's ID
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                // Convert Firestore docs into Capsule objects
                let capsules = snapshot?.documents.compactMap { doc -> Capsule? in
                    return Capsule.fromDictionary(doc.data())
                }
                completion(capsules, nil)
            }
    }
    
    // Get only the saved capsules for a user
    func fetchSavedCapsules(for userId: String, completion: @escaping ([Capsule]?, Error?) -> Void) {
        db.collection("capsules")
            .whereField("userId", isEqualTo: userId)
            .whereField("isSaved", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }

                let capsules = snapshot?.documents.compactMap { doc in
                    Capsule.fromDictionary(doc.data())
                }

                completion(capsules, nil)
            }
    }
}

