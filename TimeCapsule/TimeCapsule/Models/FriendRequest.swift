import Foundation

struct FriendRequest: Identifiable, Codable {
  let id: String       // the requester’s uid
  let status: String   // "pending", "accepted", or "declined"
}
