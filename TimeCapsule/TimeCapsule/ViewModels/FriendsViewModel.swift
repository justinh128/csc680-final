import Foundation
import FirebaseFirestore
import FirebaseAuth

// Handles friends list, requests, and responses
class FriendsViewModel: ObservableObject {
    @Published var myFriends: [AppUser] = []
    @Published var incomingRequests: [FriendRequest] = []
    @Published var incomingRequestUsers: [AppUser] = []

    let db = Firestore.firestore()

    // Call this after login is confirmed
    func fetchAll() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }

        fetchFriends(for: currentUid)
        fetchRequests(for: currentUid)
    }
    
    // Get the current user's accepted friends
    func fetchFriends(for uid: String) {
        db.collection("users")
          .document(uid)
          .collection("friends")
          .getDocuments { snap, error in
            guard let docs = snap?.documents, error == nil else { return }
            let friendIds = docs.map { $0.documentID }
            // Load user info for each friend
            self.loadUsers(uids: friendIds) { users in
                DispatchQueue.main.async {
                    self.myFriends = users
                }
            }
        }
    }

    // Get all incoming friend requests
    func fetchRequests(for uid: String) {
        db.collection("users")
          .document(uid)
          .collection("friendRequests")
          .whereField("status", isEqualTo: "pending")
          .getDocuments { snap, error in
            guard let docs = snap?.documents, error == nil else { return }

            // Convert Firestore docs to FriendRequest objects
            let reqs = docs.map { doc in
                FriendRequest(id: doc.documentID,
                              status: doc["status"] as? String ?? "pending")
            }

            DispatchQueue.main.async {
                self.incomingRequests = reqs
            }

            // Load user info for each request sender
            let requesterIds = reqs.map { $0.id }
            self.loadUsers(uids: requesterIds) { users in
                DispatchQueue.main.async {
                    self.incomingRequestUsers = users
                }
            }
        }
    }

    // Load user info (AppUser) from a list of user IDs
    func loadUsers(uids: [String], completion: @escaping ([AppUser]) -> Void) {
        var users: [AppUser] = []
        let group = DispatchGroup()

        for id in uids {
            group.enter()
            db.collection("users")
              .document(id)
              .getDocument { doc, error in
                defer { group.leave() }
                guard let data = doc?.data(), error == nil,
                      let email = data["email"] as? String else { return }
                users.append(AppUser(id: id, displayName: email, email: email))
            }
        }

        group.notify(queue: .main) {
            completion(users)
        }
    }

    // Send a friend request to another user by UID
    func sendRequest(to friendUid: String) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            print("Cannot send request — not logged in.")
            return
        }
        db.collection("users")
          .document(friendUid)
          .collection("friendRequests")
          .document(myUid)
          .setData(["status": "pending"])
    }

    // Accept or decline a friend request
    func respond(to request: FriendRequest, accept: Bool) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            print("Cannot respond to request — not logged in.")
            return
        }
        let otherUid = request.id
        let status = accept ? "accepted" : "declined"
        let myReqRef = db.collection("users")
                         .document(myUid)
                         .collection("friendRequests")
                         .document(otherUid)

        myReqRef.updateData(["status": status]) { error in
            if let error = error {
                print("Error updating request:", error.localizedDescription)
                return
            }

            if accept {
                // Add each other to the friends list
                let meRef   = self.db.collection("users").document(myUid)
                                      .collection("friends")
                                      .document(otherUid)
                let themRef = self.db.collection("users").document(otherUid)
                                      .collection("friends")
                                      .document(myUid)

                let since = Timestamp(date: Date())
                meRef.setData(["since": since])
                themRef.setData(["since": since])
            }

            // Refresh both lists
            DispatchQueue.main.async {
                self.fetchAll()
            }
        }
    }
    
    // Remove a friend from both users’ lists
    func removeFriend(_ friendUid: String) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            print("Cannot remove friend — not logged in.")
            return
        }
        
        let meRef   = db.collection("users")
                         .document(myUid)
                         .collection("friends")
                         .document(friendUid)
        let themRef = db.collection("users")
                         .document(friendUid)
                         .collection("friends")
                         .document(myUid)

        // Delete both sides
        meRef.delete { error in
            if let error = error {
                print("Error removing friend from my list:", error.localizedDescription)
                return
            }
            themRef.delete { error in
                if let error = error {
                    print("Error removing me from friend’s list:", error.localizedDescription)
                    return
                }
                // Refresh UI
                DispatchQueue.main.async {
                    self.fetchFriends(for: myUid)
                }
            }
        }
    }
}
