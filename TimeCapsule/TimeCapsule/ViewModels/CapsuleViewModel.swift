import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Manages all capsule data (sent and received)
class CapsuleViewModel: ObservableObject {
    @Published var receivedCapsules: [Capsule] = []
    @Published var sentCapsules: [Capsule] = []

    private let db = Firestore.firestore()
    private var uid: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        startUnlockCheck()
        fetchCapsules()
    }
    // This helps update the UI in real time as unlock times are reached
    private func startUnlockCheck() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    // Create and save a new capsule
    func addCapsule(
        title: String,
        message: String,
        unlockDate: Date,
        recipientId: String,
        senderId: String?,
        senderEmail: String?,
        imageURL: String?
    ) {
        guard let me = uid else { return }

        let newCapsule = Capsule(
            id: UUID().uuidString,
            title: title,
            message: message,
            unlockDate: unlockDate,
            userId: recipientId,
            senderId: senderId,
            senderEmail: senderEmail,
            imageURL: imageURL,
            isSaved: false
        )
        // Save capsule to Firestore
        db.collection("capsules")
          .document(newCapsule.id)
          .setData(newCapsule.toDictionary()) { error in
            if let error = error {
                print("Error saving capsule:", error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if recipientId == me {
                        self.receivedCapsules.append(newCapsule)
                    } else {
                        self.sentCapsules.append(newCapsule)
                    }
                }
            }
          }
    }

    func fetchCapsules() {
        guard let me = uid else { return }

        // Get capsules where I’m the recipient (including ones I made for myself)
        db.collection("capsules")
          .whereField("userId", isEqualTo: me)
          .getDocuments { snap, error in
            guard let docs = snap?.documents, error == nil else {
                print("Error fetching received capsules:", error?.localizedDescription ?? "")
                return
            }
            let caps = docs.compactMap { Capsule.fromDictionary($0.data()) }
            DispatchQueue.main.async {
                self.receivedCapsules = caps.sorted { $0.unlockDate < $1.unlockDate }
            }
        }

        // Get capsules I’ve sent to friends
        db.collection("capsules")
          .whereField("senderId", isEqualTo: me)
          .getDocuments { snap, error in
            guard let docs = snap?.documents, error == nil else {
                print("Error fetching sent capsules:", error?.localizedDescription ?? "")
                return
            }
            let caps = docs.compactMap { Capsule.fromDictionary($0.data()) }
            DispatchQueue.main.async {
                self.sentCapsules = caps.sorted { $0.unlockDate < $1.unlockDate }
            }
        }
    }
}
