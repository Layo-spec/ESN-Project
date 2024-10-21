import SwiftUI

struct TermsAndConditionsView: View {
    let groupTitle: String // Group title passed in to track acceptance
    @State private var navigateToOptions = false // State to trigger navigation to the options view

    var body: some View {
        VStack {
            Text("Terms and Conditions")
                .font(.title)
                .bold()
                .padding()
            
            ScrollView {
                Text("Please read and accept the terms and conditions before proceeding.")
                    .padding()
                Text("The ESN App terms state that users are responsible for how they use peer advice, as the app doesn't verify or guarantee the accuracy of user-generated content. Professional advice may be available but is also not guaranteed by the app.\n\n Users are urged to exercise caution and use their judgment when acting on any advice.The app is not liable for any harm resulting from the use of peer advice, and users must ensure the accuracy and safety of any information they share or rely on.\n\n Violating rules such as posting misleading information or engaging in harmful behavior can lead to account termination.The app's terms may change, and by continuing use, users agree to the updated conditions.")
                    .font(.body)
                    .padding()
                
            }
            
            Button(action: {
                acceptTermsForGroup(groupTitle: groupTitle)
                navigateToOptions = true // Navigate to the options after acceptance
            }) {
                Text("I Accept")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .navigationDestination(isPresented: $navigateToOptions) {
                GroupOptionsView() // Navigate to options after accepting terms
            }
        }
        .padding()
    }

    // Function to store acceptance status in UserDefaults
    private func acceptTermsForGroup(groupTitle: String) {
        UserDefaults.standard.set(true, forKey: "\(groupTitle)_termsAccepted")
    }
}


