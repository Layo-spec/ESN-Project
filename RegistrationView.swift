import SwiftUI
import PhotosUI


struct RegistrationView: View {
    @State private var name: String = ""
    @State private var email: String
    @State private var userId: String = ""
    @State private var avatar: UIImage? = nil
    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var errorMessage: String = ""
    
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    var onComplete: (String, String, UIImage?) -> Void // Callback to pass back the data

    // This is the default access level (internal) and should be accessible from UserAuthView
    init(email: String, onComplete: @escaping (String, String, UIImage?) -> Void) {
        self._email = State(initialValue: email)
        self.onComplete = onComplete
    }

    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5)
            
            TextField("User ID", text: $userId)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5)
            
            PhotosPicker(selection: $avatarItem, matching: .images) {
                Text("Choose Avatar")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .onChange(of: avatarItem) {
                if let avatarItem {
                    Task {
                        if let data = try? await avatarItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            avatar = uiImage
                        }
                    }
                }
            }
            .padding()
            
            if let avatar = avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            }
            
            Button(action: {
                if name.isEmpty || userId.isEmpty || !email.contains("@my.fisk.edu") {
                    errorMessage = "Please fill in all fields with valid email."
                } else {
                    // Call the completion handler with the user data and dismiss the view
                    onComplete(name, userId, avatar)
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Register")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            
            Text(errorMessage).foregroundColor(.red).padding()
        }.padding()
    }
}


