import SwiftUI

// This is the main screen showing all types of capsules: personal, sent, and received
struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var viewModel = CapsuleViewModel()
    
    @State private var showNewCapsuleView = false // Controls the create new capsule sheet
    @State private var selectedCapsule: Capsule?
    @State private var now = Date()

    var body: some View {
        NavigationView {
            List {
                Section("My Capsules") {
                    let myCaps = viewModel.receivedCapsules
                        // Filter out any that were received from others
                        .filter { $0.senderId == nil }
                    if myCaps.isEmpty {
                        Text("No personal capsules yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(myCaps) { cap in
                            CapsuleRow(capsule: cap)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if cap.isUnlocked { selectedCapsule = cap }
                                }
                        }
                    }
                }

                Section("Sent Capsules") {
                    if viewModel.sentCapsules.isEmpty {
                        Text("You haven't sent any yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.sentCapsules) { cap in
                            CapsuleRow(capsule: cap, isSent: true)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if cap.isUnlocked { selectedCapsule = cap }
                                }
                        }
                    }
                }

                Section("Received Capsules") {
                    let recCaps = viewModel.receivedCapsules
                        .filter { $0.senderId != nil } // Only show those sent by others
                    if recCaps.isEmpty {
                        Text("No capsules received yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(recCaps) { cap in
                            CapsuleRow(capsule: cap)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if cap.isUnlocked { selectedCapsule = cap }
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Capsule")
            // Refresh the view every second to auto-unlock capsules when time hits
            .onReceive(
              Timer.publish(every: 1, on: .main, in: .common)
                   .autoconnect()
            ) { current in
              now = current
            }
            // Toolbar button to create a new capsule
            .toolbar {
                Button(action: { showNewCapsuleView = true }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showNewCapsuleView) {
                NewCapsuleView(viewModel: viewModel)
            }
            // Show capsule details when selected
            .sheet(item: $selectedCapsule) { cap in
                CapsuleDetailView(capsule: cap)
            }
            // Fetch capsules when screen appears
            .onAppear {
                viewModel.fetchCapsules()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample data for preview
        let vm = CapsuleViewModel()
        vm.receivedCapsules = [
            Capsule(id: "1", title: "My Note", message: "Hello me!", unlockDate: Date().addingTimeInterval(3600),
                    userId: "me", senderId: nil, senderEmail: nil, imageURL: nil, isSaved: false),
            Capsule(id: "2", title: "Gift", message: "Surprise!", unlockDate: Date().addingTimeInterval(-3600),
                    userId: "me", senderId: "friend1", senderEmail: "friend@example.com", imageURL: nil, isSaved: false)
        ]
        vm.sentCapsules = [
            Capsule(id: "3", title: "Sent to Bob", message: "Hey Bob!", unlockDate: Date().addingTimeInterval(7200),
                    userId: "bob", senderId: "me", senderEmail: "me@example.com", imageURL: nil, isSaved: false)
        ]

        return HomeView(viewModel: vm)
            .environmentObject(AuthViewModel())
            .environmentObject(FriendsViewModel())
    }
}
