import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct RegistrationView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var studentId: String = ""
    @State private var email: String
    @State private var password: String = ""
    @State private var showPassword: Bool = false // showing and hiding password
    @State private var userAlias: String = ""
    @State private var avatar: UIImage? = nil
    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var errorMessage: String = ""
    @State private var isVerificationSent = false // To track email verification

    @Environment(\.presentationMode) var presentationMode
    var onComplete: (String, String, String, String, UIImage?) -> Void
    
    private let db = Firestore.firestore() // Reference to Firestore

    init(email: String, onComplete: @escaping (String, String, String, String, UIImage?) -> Void) {
        self._email = State(initialValue: email)
        self.onComplete = onComplete
    }

    var body: some View {
        VStack {
            if isVerificationSent {
                // Show a message asking the user to verify their email
                Text("A verification email has been sent to \(email). Please verify your email before logging in.")
                    .padding()
            } else {
                // registration form if verification email has not been sent
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)

                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)

                TextField("Student ID", text: $studentId)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                // Password Field with "Show" option
                ZStack {
                    if showPassword {
                        TextField("Password", text: $password) // Show password
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(5)
                    } else {
                        SecureField("Password", text: $password) // Hide password
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(5)
                    }
                                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showPassword.toggle() // Toggle password visibility
                        }) {
                            Text(showPassword ? "Hide" : "Show")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 10)
                    }
                }

                TextField("User Alias", text: $userAlias)
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

                if let avatar = avatar {
                    Image(uiImage: avatar)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }

                Button(action: {
                    registerUser()
                }) {
                    Text("Register")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }

                Text(errorMessage).foregroundColor(.red).padding()
            }
        }
        .padding()
    }

    // Function to register user in Firebase Auth and add data to Firestore
    private func registerUser() {
        // Register the user with Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Registration failed: \(error.localizedDescription)"
                return
            }

            // Once the user is created, send a verification email
            if let user = authResult?.user {
                sendVerificationEmail(user: user) // Send the email verification
            }
        }
    }

    // Function to send verification email
    private func sendVerificationEmail(user: User) {
        user.sendEmailVerification { error in
            if let error = error {
                self.errorMessage = "Error sending verification email: \(error.localizedDescription)"
            } else {
                self.isVerificationSent = true // Show the verification message
                saveUserDataToFirestore(userId: user.uid)
            }
        }
    }

    // Function to save user data to Firestore
    private func saveUserDataToFirestore(userId: String) {
        let userData: [String: Any] = [
            "firstName": self.firstName,
            "lastName": self.lastName,
            "studentId": self.studentId,
            "email": self.email,
            "userAlias": self.userAlias,
            "avatarUrl": ""
        ]

        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                self.errorMessage = "Error saving user data: \(error.localizedDescription)"
            } else {
                print("User data saved successfully.")
                onComplete(self.firstName, self.lastName, self.studentId, userId, self.avatar)
                self.presentationMode.wrappedValue.dismiss() 
            }
        }
    }
}
