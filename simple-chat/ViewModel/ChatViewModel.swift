//
//  ChatViewModel.swift
//  simple-chat
//
//  Created by Imran Abdullah on 08/09/23.
//

import Foundation
import XMPPFramework

class ChatViewModel: ObservableObject, XMPPMessageDelegate {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    var user: User
    var chatRoom: ChatRoom?
    let userJID = UserDefaults.standard.string(forKey: "currentUserJID") ?? "defaultJID"
    let userPassword = UserDefaults.standard.string(forKey: "userPassword") ?? ""
    let domain = "uatchat2.waafi.com"
    
    init(user: User) {
        self.user = user
        XMPPManager.shared.messageDelegate = self
        
        if let existingChatRoom = SQLManager.shared.fetchChatRoom(participant1Id: user.id) {
            self.chatRoom = existingChatRoom
        } else {
            // Create a new chat room and store it in the database
            let newChatRoom = ChatRoom(id: UUID(), messages: [], type: .oneOnOne(user))
            _ = SQLManager.shared.storeChatRoom(chatRoom: newChatRoom)
            self.chatRoom = newChatRoom
        }
        
        fetchPreviousMessages()
    }
    
    
    
    func fetchPreviousMessages() {
        if let chatRoom = self.chatRoom {
            self.messages = SQLManager.shared.fetchMessages(forChatRoomId: chatRoom.id) ?? []
        }
    }
    
    func connectAndFetchMessages() {
        if !XMPPManager.shared.xmppStream.isConnected {
            XMPPManager.shared.connect(hostName: domain, port: 5222, username: "\(userJID)@\(domain)", password: userPassword) { success, error in
                if success {
                    self.fetchPreviousMessages()
                } else {
                    print("Failed to connect.")
                }
            }
        } else {
            self.fetchPreviousMessages()
        }
    }
    
    func extractNumberFromJID(_ jid: String) -> String? {
        if let range = jid.range(of: "@") {
            return String(jid[..<range.lowerBound])
        }
        return nil
    }
    
    func receivedMessage(from senderJID: XMPPJID, content: String) {
        let senderId = extractNumberFromJID(senderJID.full) ?? ""
        if let sender = SQLManager.shared.fetchUser(byId: senderId) {
            let receivedMsg = Message(id: UUID(), sender: sender, content: content, timestamp: Date())
            messages.append(receivedMsg)
            if let chatRoom = self.chatRoom {
                _ = SQLManager.shared.storeMessage(message: receivedMsg, in: chatRoom)
            }
        } else {
            print("Failed to fetch user with id: \(senderId)")
        }
    }
        
        func sendMessage() {
            // Inner function to handle the sending logic
            func send() {
                XMPPManager.shared.sendMessage(to: "\(user.id)@uatchat2.waafi.com", content: newMessage, onSuccess: {
                    if let currentUserJID = XMPPManager.shared.xmppStream.myJID?.user,
                       let currentUser = SQLManager.shared.fetchUser(byId: currentUserJID) {
                        // Create a message instance with the current user as the sender
                        let outgoingMsg = Message(id: UUID(), sender: currentUser, content: self.newMessage, timestamp: Date())
                        self.messages.append(outgoingMsg)
                        
                        // Store the sent message in the database
                        if let chatRoom = self.chatRoom {
                            _ = SQLManager.shared.storeMessage(message: outgoingMsg, in: chatRoom)
                        }
                        
                        // Clear the message input after sending
                        self.newMessage = ""
                    } else {
                        print("Failed to fetch current user for message sending")
                    }
                }, onFailure: { error in
                    print("Failed to send message via XMPP: \(error.localizedDescription)")
                })
            }
            
            // Check if the XMPP connection is active
            if !XMPPManager.shared.xmppStream.isConnected {
                XMPPManager.shared.connect(hostName: domain, port: 5222, username: "\(userJID)@\(domain)", password: userPassword) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            send()
                        } else {
                            print("Failed to connect before sending the message.")
                        }
                    }
                }
            } else {
                send()
            }
        }
}
