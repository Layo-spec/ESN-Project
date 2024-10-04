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
    @State private var errorMessage: String = ""
    @State private var keepLoggedIn = false
    @State private var navigationPath: [AuthNavigation] = [] // Use a stack for navigation
    
    @State private var registeredEmails: Set<String> = []
    @State private var userInfo: [String: (userId: String, avatar: UIImage?)] = [:] // Key: email, Value: (userId, avatar)
    
    var body: some View {
        NavigationStack(path: $navigationPath) { // NavigationStack replaces NavigationView
            VStack {
                Text("ESN")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40) // Add padding above the title
                    .padding(.bottom, 20) // Add padding below the title
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                Button(action: {
                    handleAction()
                }) {
                    Text("Login")
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5)
                        .foregroundColor(.white)
                }
                
                Text(errorMessage).foregroundColor(.red).padding()
                
                // Use a NavigationLink with value instead of destination
                NavigationLink(value: AuthNavigation.registration(email: email)) {
                    EmptyView() // You can trigger navigation here, no need for a label
                }
            }
            .padding()
            .navigationDestination(for: AuthNavigation.self) { destination in
                switch destination {
                case .registration(let email):
                    RegistrationView(email: email, onComplete: { name, userId, avatar in
                        // Register user info here
                        registeredEmails.insert(email)
                        userInfo[email] = (userId: userId, avatar: avatar) // Store the userId and avatar
                        navigationPath.append(.supportGroups) // Navigate to support groups after registration
                    })
                case .supportGroups:
                    SupportGroupView()
                }
            }
        }
    }
    
    private func handleAction() {
        guard email.contains("@my.fisk.edu") else {
            errorMessage = "Email must contain @my.fisk.edu"
            return
        }
        
        if registeredEmails.contains(email) {
            // User is already registered, proceed with anonymous login
            logInAnonymously()
        } else {
            errorMessage = "Email not registered. Please create an account."
            navigationPath.append(.registration(email: email)) // Trigger registration if email not found
        }
    }

    private func logInAnonymously() {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                // Log the error details for debugging
                print("Error signing in anonymously: \(error.localizedDescription)")
                errorMessage = "Login failed: \(error.localizedDescription)"
                return
            }
            
            // Successfully logged in anonymously
            if let user = authResult?.user {
                userInfo[email] = (userId: user.uid, avatar: nil) // Store the user ID and avatar as nil initially
                navigationPath.append(.supportGroups) // Navigate to support groups
            }
        }
    }

}
#Preview{
    UserAuthView()
}
