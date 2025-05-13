import SwiftUI

// This screen displays all capsules the user has marked as "Saved"
struct SavedView: View {
    @StateObject var viewModel = SavedCapsulesViewModel() // ViewModel to fetch saved capsules
    @State private var selectedCapsule: Capsule? // Stores the capsule selected for viewing

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Loop through each saved capsule
                    ForEach(viewModel.savedCapsules) { capsule in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(capsule.title)
                                .font(.headline)

                            Text(capsule.message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // If the capsule has an image, load and display it
                            if let imageURL = capsule.imageURL,
                               let url = URL(string: imageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 120)
                                            .clipped()
                                            .cornerRadius(8)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 120)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            // Show a "Saved" label with a bookmark icon
                            HStack {
                                Spacer()
                                Label("Saved", systemImage: "bookmark.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            selectedCapsule = capsule
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Saved Capsules")
            .onAppear {
                viewModel.fetchSavedCapsules()
            }
            .sheet(item: $selectedCapsule) { capsule in
                CapsuleDetailView(capsule: capsule)
            }
        }
    }
}
