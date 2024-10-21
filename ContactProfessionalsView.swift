import SwiftUI

struct ContactProfessionalsView: View {
    var body: some View {
        VStack {
            Text("Contact Professionals")
                .font(.title)
                .bold()
                .padding()

            // Example professional's contact information
            VStack(alignment: .leading) {
                Text("Name: Dr. Jane Doe")
                Text("Email: jane.doe@ESNApp.com")
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}
