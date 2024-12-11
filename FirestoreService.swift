import Firebase
import FirebaseFirestore
import SwiftUI
import FirebaseAuth

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var messages = [Message]()
    private var listener: ListenerRegistration?
    
    func fetchJoinDate(groupID: String, userID: String, completion: @escaping (Timestamp?) -> Void) {
        let userRef = db.collection("support_groups").document(groupID).collection("members").document(userID)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching join date: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let document = document, document.exists else {
                print("Document does not exist for groupID: \(groupID), userID: \(userID)")
                completion(nil)
                return
            }
            let joinDate = document.get("joinedDate") as? Timestamp
            completion(joinDate)
        }
    }

    func listenToMessages(groupID: String, joinDate: Timestamp) {
        listener?.remove()
        listener = db.collection("support_groups")
            .document(groupID)
            .collection("messages")
            .whereField("timestamp", isGreaterThan: joinDate)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }

                self.messages = documents.compactMap { doc in
                    let data = doc.data()
                    
                    // Safely unwrap all required values
                    guard
                        let userID = data["userID"] as? String,
                        let text = data["messageText"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    else {
                        print("Missing data in document \(doc.documentID)")
                        return nil // Skip this document if any required field is missing
                    }
                    
                    // Optional field for imageURL
                    let imageURL = data["imageURL"] as? String
                    let deleted = data["deleted"] as? Bool ?? false
                    
                    return Message(
                        id: doc.documentID,
                        userID: userID,
                        text: text,
                        imageURL: imageURL,
                        timestamp: timestamp,
                        deleted: deleted
                    )
                }.filter { !$0.deleted } // Filter out messages marked as deleted
            }
    }
    func sendMessage(groupID: String, userID: String, text: String, imageURL: String? = nil) {
        let messageData: [String: Any] = [
            "userID": userID,
            "messageText": text,
            "timestamp": Timestamp(date: Date()),
            "imageURL": imageURL ?? "",
            "deleted": false
        ]
        db.collection("support_groups")
          .document(groupID)
          .collection("messages")
          .addDocument(data: messageData)
    }

    func deleteMessage(groupID: String, messageID: String) {
        db.collection("support_groups")
          .document(groupID)
          .collection("messages")
          .document(messageID)
          .updateData(["deleted": true])
    }

    func removeListener() {
        listener?.remove()
    }
    
}
