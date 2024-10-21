import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

// Enum to define navigation path
enum AuthNavigation: Hashable {
    case registration(email: String)
    case supportGroups
}

struct UserAuthView: View {
    @State private var email: String = ""
    @State private var password: String = "" // State for password
    @State private var errorMessage: String = ""
    @State private var keepLoggedIn = false // State for 'Keep me logged in'
    @State private var showPasswordResetAlert = false // To control alert for password reset
    @State private var navigationPath: [AuthNavigation] = [] // Stack for navigation
    
    @State private var registeredEmails: Set<String> = [] // Set for storing registered emails
    @State private var userInfo: [String: (userId: String, avatar: UIImage?)] = [:] // Store user info

    @Environment(\.scenePhase) var scenePhase // Detect app activity
    private let db = Firestore.firestore() // Firestore database reference

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Text("ESN")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password) // Password field
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)

                Toggle("Keep me logged in", isOn: $keepLoggedIn)
                    .padding()

                Button(action: {
                    handleLogin() // Use the updated login handler
                }) {
                    Text("Login")
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5)
                        .foregroundColor(.white)
                }
                // Forget Password button
                Button(action: {
                    sendPasswordReset() // Trigger password reset function
                }) {
                    Text("Forgot Password?")
                        .padding(.top, 10)
                        .foregroundColor(.blue)
                }
                
                Text(errorMessage).foregroundColor(.red).padding()
                
                NavigationLink(value: AuthNavigation.registration(email: email)) {
                    EmptyView() // Trigger navigation here if needed
                }
            }
            .padding()
            .navigationDestination(for: AuthNavigation.self) { destination in
                switch destination {
                case .registration(let email):
                    RegistrationView(email: email, onComplete: { firstName, lastName, studentId, userId, avatar in
                        registeredEmails.insert(email)
                        userInfo[email] = (userId: userId, avatar: avatar)
                        navigationPath.append(.supportGroups) // Navigate to support groups
                    })
                case .supportGroups:
                    SupportGroupView()
                }
            }
            .onChange(of: scenePhase) { oldPase, newPhase in
                if newPhase == .inactive || newPhase == .background {
                    scheduleAutoLogout() // Handle auto logout after inactivity
                }
            }
            .alert(isPresented: $showPasswordResetAlert) {
                Alert(title: Text("Password Reset"), message: Text("A password reset link has been sent to \(email). Please check your inbox."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Function to Handle login
    private func handleLogin() {
        // Check if email contains the correct domain
        guard email.contains("@my.fisk.edu") else {
            errorMessage = "Email must contain '@my.fisk.edu'"
            return
        }

        // Check if the email is already registered
        checkIfUserExists { exists in
            if exists {
                // Proceed with login if the user is already registered
                logInWithEmailPassword()
            } else {
                // Redirect to the registration page if the user is not registered
                errorMessage = "Email not registered. Redirecting to registration..."
                navigationPath.append(.registration(email: email))
            }
        }
    }
    
    // Function to check if a user already exists in the Firestore database
    private func checkIfUserExists(completion: @escaping (Bool) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Error checking user registration: \(error.localizedDescription)"
                completion(false)
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                completion(true) // User exists
            } else {
                completion(false) // User does not exist
            }
        }
    }

    // Function for logging in with email and password
    private func logInWithEmailPassword() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Login failed: \(error.localizedDescription)")
                errorMessage = "Login failed: Make sure your email and password are correct."
                return
            }
            
            if keepLoggedIn {
                // Do nothing, Firebase automatically persists user sessions
                print("User will remain logged in across sessions.")
            } else {
                // Set a timer to log out after 10 minutes of inactivity
                scheduleAutoLogout()
            }

            // Successfully logged in
            if let user = authResult?.user {
                if user.isEmailVerified {
                    userInfo[email] = (userId: user.uid, avatar: nil)
                    navigationPath.append(.supportGroups)
                } else {
                    errorMessage = "Please verify your email."
                    // Inform the user that they need to verify their email
                    sendVerificationEmail()
                }
            }
        }
    }
    
    // Function to auto logout after 10 minutes of inactivity
    private func scheduleAutoLogout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 600) {
            do {
                try Auth.auth().signOut()
                navigationPath.removeAll() // Clear navigation after logging out
                print("User logged out due to inactivity.")
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
        }
    }

    // Send verification email
    private func sendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { error in
            if let error = error {
                print("Failed to send verification email: \(error.localizedDescription)")
            } else {
                print("Verification email sent.")
            }
        }
    }
    
    // Function to send password reset email
    private func sendPasswordReset() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address to reset your password."
            return
        }
            
            // Firebase password reset function
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
            } else {
                showPasswordResetAlert = true 
            }
        }
    }
}
