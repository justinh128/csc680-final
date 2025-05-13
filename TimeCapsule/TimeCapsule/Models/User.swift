import Foundation

struct AppUser: Identifiable, Codable {
  let id: String
  let displayName: String
  let email: String
}

