import SwiftUI

// This screen shows your friends list and friend requests
struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel() // ViewModel for managing friends and requests
    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            List {
                // Section for showing current friends
                Section("Your Friends") {
                    if vm.myFriends.isEmpty {
                        Text("You have no friends yet.")
                            .foregroundColor(.secondary)
                    } else {
                        // Show each friend’s email
                        ForEach(vm.myFriends) { user in
                            Text(user.email)
                        }
                        .onDelete { indexSet in
                            // Allow swipe-to-delete on friends
                            let uidsToRemove = indexSet.map { vm.myFriends[$0].id }
                            for uid in uidsToRemove {
                                vm.removeFriend(uid)
                            }
                        }
                    }
                }

                // For showing incoming friend requests
                Section("Requests") {
                    if vm.incomingRequests.isEmpty {
                        Text("No pending requests")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(vm.incomingRequests) { req in
                            // Try to get the sender’s email from the user list
                            let requester = vm.incomingRequestUsers
                                .first(where: { $0.id == req.id })

                            HStack {
                                // Show email or fallback to ID if missing
                                Text(requester?.email ?? req.id)
                                Spacer()
                                Button("Accept") {
                                    vm.respond(to: req, accept: true)
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Decline") {
                                    vm.respond(to: req, accept: false)
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .listStyle(.insetGrouped)
            .navigationTitle("Friends")
            .toolbar {
                Button { showingAdd = true } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddFriendView(vm: vm)
            }
        }
        .onAppear {
            vm.fetchAll()
        }
    }
}
