import Foundation
import FirebaseFirestore

// Represents a time capsule
struct Capsule: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let unlockDate: Date
    let userId: String        // who can open this capsule
    let senderId: String?     // if sent to you, who created it
    let senderEmail: String?  // email of the sender at creation time

    var imageURL: String?     // optional picture
    var isSaved: Bool = false // saved flag

    // Check if it's ready to open
    var isUnlocked: Bool {
        Date() >= unlockDate
    }

    // Convert capsule into Firestore dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "message": message,
            "unlockDate": Timestamp(date: unlockDate),
            "userId": userId,
            "isSaved": isSaved
        ]
        // Add optional fields if they exist
        if let senderId = senderId {
            dict["senderId"] = senderId
        }
        if let senderEmail = senderEmail {
            dict["senderEmail"] = senderEmail
        }
        if let imageURL = imageURL {
            dict["imageURL"] = imageURL
        }
        return dict
    }

    // Convert Firestore data into Capsule
    static func fromDictionary(_ dict: [String: Any]) -> Capsule? {
        guard
            let id            = dict["id"] as? String,
            let title         = dict["title"] as? String,
            let message       = dict["message"] as? String,
            let unlockTS      = dict["unlockDate"] as? Timestamp,
            let userId        = dict["userId"] as? String,
            let isSaved       = dict["isSaved"] as? Bool
        else { return nil }

        let senderId    = dict["senderId"] as? String
        let senderEmail = dict["senderEmail"] as? String
        let imageURL    = dict["imageURL"] as? String

        return Capsule(
            id: id,
            title: title,
            message: message,
            unlockDate: unlockTS.dateValue(),
            userId: userId,
            senderId: senderId,
            senderEmail: senderEmail,
            imageURL: imageURL,
            isSaved: isSaved
        )
    }
}
