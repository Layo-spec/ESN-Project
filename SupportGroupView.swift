import SwiftUI


struct SupportGroup: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let description: String
}

// Main view for support groups
struct SupportGroupView: View {
    @State private var searchText = ""
    @State private var currentTab = 0
    @State private var showTermsAndConditions = false
    @State private var navigateToOptions = false
    
    // Sample support groups with images
    let supportGroups = [
        SupportGroup(title: "Depression", imageName: "depressionImage", description: "A group to share and support individuals facing depression."),
        SupportGroup(title: "Academics", imageName: "academicsImage", description: "Discuss academic-related stress and concerns."),
        SupportGroup(title: "Office Of Career Planning", imageName: "careerPlanningImage", description: "Leadership, empowerment, and development discussions."),
        SupportGroup(title: "Office Of Global initiatives", imageName: "globalInitiativeImage", description: "Support group for international students and global issues.")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Peer Support Groups")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                    .foregroundColor(.white)
                
                
                TextField("Search", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                
                ScrollView {
                    if filteredGroups.isEmpty {
                        Text("No support groups found")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(filteredGroups) { group in
                                GroupNavigationLink(group: group)
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                // Taskbar at the bottom with interactive tabs
                HStack {
                    Spacer()
                    TabBarItem(icon: "message.fill", label: "Support Group", isActive: currentTab == 0)
                        .onTapGesture { currentTab = 0 }
                    Spacer()
                    TabBarItem(icon: "person.2.fill", label: "Students", isActive: currentTab == 1)
                        .onTapGesture { currentTab = 1 }
                    Spacer()
                    TabBarItem(icon: "calendar", label: "Weekly Meetings", isActive: currentTab == 2)
                        .onTapGesture { currentTab = 2 }
                    Spacer()
                    TabBarItem(icon: "person.circle", label: "Profile", isActive: currentTab == 3)
                        .onTapGesture { currentTab = 3 }
                    Spacer()
                }
                .frame(height: 60)
                .background(Color(.systemGray6))
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    // Function to filter the support groups based on search input
    var filteredGroups: [SupportGroup] {
        if searchText.isEmpty {
            return supportGroups
        } else {
            return supportGroups.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct GroupNavigationLink: View {
    let group: SupportGroup
    @State private var showTermsAndConditions = false
    @State private var navigateToOptions = false

    var body: some View {
        VStack {
            Image(group.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .cornerRadius(8)
                .clipped()
            
            Text(group.title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 5)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 5)
        .onTapGesture {
            handleGroupSelection(group: group)
        }
        // Navigation destinations for both options and terms
        .navigationDestination(isPresented: $showTermsAndConditions) {
            TermsAndConditionsView(groupTitle: group.title)
        }
        .navigationDestination(isPresented: $navigateToOptions) {
            GroupOptionsView()
        }
    }

    // Function to handle group selection based on terms acceptance
    private func handleGroupSelection(group: SupportGroup) {
        if hasAcceptedTerms(for: group.title) {
            navigateToOptions = true // Directly go to options if terms were accepted
        } else {
            showTermsAndConditions = true // Show terms if not accepted
        }
    }

    // Function to check if the user has accepted the terms for the group
    private func hasAcceptedTerms(for groupTitle: String) -> Bool {
        // Check UserDefaults to see if the user has accepted the terms for this group
        return UserDefaults.standard.bool(forKey: "\(groupTitle)_termsAccepted")
    }
}


// view for individual support groups
struct GroupDetailView: View {
    let group: SupportGroup
    @State private var showTermsAndConditions = false // State to show terms and conditions
    @State private var navigateToOptions = false // State to skip terms and conditions

    var body: some View {
        VStack {
            Text(group.title)
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text(group.description)
                .padding()
            
            Spacer()
            
            // Check if the user has already accepted the terms and conditions
            Button(action: {
                if hasAcceptedTerms(for: group.title) {
                    navigateToOptions = true // Skip terms and show options
                } else {
                    showTermsAndConditions = true // Show terms and conditions if not accepted
                }
            }) {
                Text("Join Group")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .navigationDestination(isPresented: $showTermsAndConditions) {
                TermsAndConditionsView(groupTitle: group.title)
            }
            .navigationDestination(isPresented: $navigateToOptions) {
                GroupOptionsView()
            }
        }
        .padding()
    }

    // Function to check if the user has accepted the terms for the group
    private func hasAcceptedTerms(for groupTitle: String) -> Bool {
        // Check to see if the user has accepted the terms for this group
        return UserDefaults.standard.bool(forKey: "\(groupTitle)_termsAccepted")
    }
}

// Tab Bar Items
struct TabBarItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isActive ? Color.blue : Color.gray)
            Text(label)
                .font(.caption)
                .foregroundColor(isActive ? Color.blue : Color.gray)
        }
    }
}





struct GroupOptionsView: View {
    @State private var navigateToContacts = false // State for navigation to contact professionals
    @State private var navigateToChat = false // State for navigation to chat

    var body: some View {
        VStack {
            Text("Choose an Option")
                .font(.title)
                .bold()
                .padding()

            Button(action: {
                navigateToContacts = true // Navigate to contact professionals
            }) {
                Text("Contact Professionals")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .navigationDestination(isPresented: $navigateToContacts) {
                ContactProfessionalsView() // Navigate to contact professionals
            }

            Button(action: {
                navigateToChat = true // Navigate to chat view
            }) {
                Text("Go to Chat")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
            .navigationDestination(isPresented: $navigateToChat) {
                ChatView() // Navigate to chat view
            }
        }
        .padding()
    }
}






#Preview {
    SupportGroupView()
}
