
//  SupportGroupView.swift
//  ESN
//
//  Created by Ebenezer Appiah on 10/03/24.
//

import SwiftUI

struct SupportGroup: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct SupportGroupView: View {
    
    let supportGroups = [
        SupportGroup(title: "Depression", description: "A group to share and support individuals facing depression."),
        SupportGroup(title: "Academics", description: "A group to discuss academic-related stress and concerns."),
        SupportGroup(title: "LEAD", description: "Leadership, empowerment, and development discussions."),
        SupportGroup(title: "Office of Global Initiative", description: "Support group for international students and global issues.")
    ]
    
    var body: some View {
        List(supportGroups) { group in
            NavigationLink(destination: GroupDetailView(group: group)) {
                VStack(alignment: .leading) {
                    Text(group.title)
                        .font(.headline)
                    Text(group.description)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Peer Support Groups") // Set the title here
    }
}

struct GroupDetailView: View {
    let group: SupportGroup
    
    var body: some View {
        VStack {
            Text(group.title)
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text(group.description)
                .padding()
            
            Spacer()
            
            Button(action: {
                // Join group logic here
                print("Joined \(group.title)")
            }) {
                Text("Join Group")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
#Preview{
    SupportGroupView()
}



