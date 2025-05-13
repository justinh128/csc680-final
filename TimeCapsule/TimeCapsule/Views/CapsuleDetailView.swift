import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// This screen shows the full details of a capsule after it's unlocked
struct CapsuleDetailView: View {
    let capsule: Capsule
    @Environment(\.dismiss) private var dismiss
    @State private var isSaved: Bool

    // Store capsule info and its saved state
    init(capsule: Capsule) {
        self.capsule = capsule
        _isSaved = State(initialValue: capsule.isSaved)
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text(capsule.title)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text(capsule.message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if let urlString = capsule.imageURL,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 300)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()
            
            // Save/Delete/Mark as Read buttons
            HStack(spacing: 20) {
                Button(isSaved ? "Unsave" : "Save") {
                    toggleSavedStatus()
                }
                .buttonStyle(.borderedProminent)

                Button("Delete", role: .destructive) {
                    deleteCapsule()
                }
                .buttonStyle(.bordered)

                Button("Mark as Read") {
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .navigationTitle("Capsule")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Toggle saved status in Firestore
    private func toggleSavedStatus() {
        let newStatus = !isSaved
        let db = Firestore.firestore()
        db.collection("capsules").document(capsule.id).updateData([
            "isSaved": newStatus
        ]) { error in
            if let error = error {
                print("Failed to update saved status:", error.localizedDescription)
            } else {
                isSaved = newStatus
            }
        }
    }

    // Delete capsule from Firestore
    private func deleteCapsule() {
        let db = Firestore.firestore()
        db.collection("capsules").document(capsule.id).delete { error in
            if let error = error {
                print("Failed to delete capsule:", error.localizedDescription)
            } else {
                dismiss()
            }
        }
    }
}
