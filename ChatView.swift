import Firebase
import FirebaseFirestore
import SwiftUI

struct ChatView: View {
    @StateObject private var firestoreService = FirestoreService()
    @State private var messageText = ""
    var groupID: String
    var userID: String
    var joinDate: Timestamp

    var body: some View {
        VStack {
            // Display messages
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(firestoreService.messages, id: \.id) { message in
                        HStack {
                            if message.userID == userID {
                                Spacer()
                                MessageBubble(message: message.text, isCurrentUser: true)
                            } else {
                                MessageBubble(message: message.text, isCurrentUser: false)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
                .onChange(of: firestoreService.messages) { oldValue, newValue in
                    if let lastMessage = newValue.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }

            // Input field and send button
            HStack {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)
                Button(action: {
                    if !messageText.isEmpty {
                        firestoreService.sendMessage(groupID: groupID, userID: userID, text: messageText)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .padding()
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            firestoreService.listenToMessages(groupID: groupID, joinDate: joinDate)
        }
        .onDisappear {
            firestoreService.removeListener()
        }
    }
}

struct MessageBubble: View {
    let message: String
    let isCurrentUser: Bool

    var body: some View {
        Text(message)
            .padding()
            .foregroundColor(isCurrentUser ? .white : .black)
            .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
            .cornerRadius(10)
            .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
    }
}

