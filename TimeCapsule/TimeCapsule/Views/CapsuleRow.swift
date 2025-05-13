import SwiftUI

// This view shows a single capsule in a list row format
struct CapsuleRow: View {
    let capsule: Capsule
    var isSent: Bool = false // Determines if this row is for a sent capsule

    @EnvironmentObject private var friendsVM: FriendsViewModel
    // Used to update the UI in real-time
    @State private var now: Date = Date()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(capsule.title)
                    .font(.headline)

                // Show who the capsule is for or from
                if isSent {
                    // Get the friend's email based on their user ID
                    let recipientEmail = friendsVM.myFriends
                        .first(where: { $0.id == capsule.userId })?
                        .email ?? "Unknown"
                    Text("To: \(recipientEmail)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                else if let sender = capsule.senderEmail {
                    Text("From: \(sender)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Show if the capsule is unlocked or when it will be
                if capsule.isUnlocked {
                    Text("Unlocked")
                        .font(.subheadline)
                        .foregroundColor(.green)
                } else {
                    Text("Opens on \(capsule.unlockDate, formatter: fullDateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: capsule.isUnlocked ? "lock.open" : "lock")
                .foregroundColor(capsule.isUnlocked ? .green : .gray)
        }
        .padding(.vertical, 8)
        .onReceive(
            Timer.publish(every: 1, on: .main, in: .common)
                 .autoconnect()
        ) { time in
            now = time
        }
    }
}

// Used to display date and time in a readable format
private let fullDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f
}()

