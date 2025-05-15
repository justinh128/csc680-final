import SwiftUI
import PhotosUI
import FirebaseStorage

// View for creating a new capsule
struct NewCapsuleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var friendsVM: FriendsViewModel
    @ObservedObject var viewModel: CapsuleViewModel

    @State private var title = ""
    @State private var message = ""
    @State private var unlockDate = Date()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    // nil = send to self; otherwise send to friend (by userId)
    @State private var recipientId: String? = nil

    var body: some View {
        NavigationView {
            Form {
                // Choose recipient (self or friend)
                Section(header: Text("Send To")) {
                    Picker("Recipient", selection: $recipientId) {
                        Text("Me").tag(String?.none)
                        ForEach(friendsVM.myFriends) { friend in
                            Text(friend.email)
                                .tag(String?.some(friend.id))
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Title")) {
                    TextField("Enter title…", text: $title)
                }

                Section(header: Text("Message")) {
                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Enter message…")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                        TextEditor(text: $message)
                            .frame(minHeight: 100, maxHeight: 150)
                    }
                }

                Section(header: Text("Unlock Date & Time")) {
                    HStack {
                        Spacer()
                        DatePicker(
                            "",
                            selection: $unlockDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                        Spacer()
                    }
                }

                Section(header: Text("Image (optional)")) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            Image(systemName: "photo")
                            Text(selectedImageData == nil ? "Select Image" : "Image Selected")
                        }
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        guard let newItem = newItem else { return }
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }

                    if let data = selectedImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Button("Save Capsule") { saveCapsule() }
                            .buttonStyle(.borderedProminent)
                        Spacer()
                        Button("Cancel") { dismiss() }
                            .buttonStyle(.bordered)
                        Spacer()
                    }
                }
            }
            .onAppear {
                friendsVM.fetchAll()
            }
            .navigationTitle("New Capsule")
        }
    }
    
    // Save the capsule to Firestore
    private func saveCapsule() {
        guard let me = authViewModel.firebaseUser else { return }

        // Determine recipient vs sender
        let actualRecipient = recipientId ?? me.uid
        let senderId    = (recipientId == nil ? nil : me.uid)
        let senderEmail = (recipientId == nil ? nil : me.email)

        let commit: (String?) -> Void = { imageURL in
            viewModel.addCapsule(
                title: title,
                message: message,
                unlockDate: unlockDate,
                recipientId: actualRecipient,
                senderId: senderId,
                senderEmail: senderEmail,
                imageURL: imageURL
            )
            dismiss()
        }

        // If an image is selected, upload first
        if let data = selectedImageData {
            uploadImage(data: data) { url in
                commit(url?.absoluteString)
            }
        } else {
            commit(nil)
        }
    }
    
    // Upload image to Firebase Storage
    private func uploadImage(data: Data, completion: @escaping (URL?) -> Void) {
        let filename = UUID().uuidString + ".jpg"
        let ref = Storage.storage()
            .reference()
            .child("capsule_images/\(filename)")

        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Upload error:", error.localizedDescription)
                completion(nil)
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("DownloadURL error:", error.localizedDescription)
                    completion(nil)
                } else {
                    completion(url)
                }
            }
        }
    }
}
