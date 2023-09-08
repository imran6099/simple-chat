//
//  GroupChatViewModel.swift
//  simple-chat
//
//  Created by Imran Abdullah on 07/09/23.
//

import Foundation
import XMPPFramework

class GroupChatViewModel: ObservableObject, XMPPMessageDelegate {
    
    @Published var messages: [Message] = []
    var chatRoom: ChatRoom?
    
    let userJID: String
    let userPassword: String
    let domain = "uatchat2.waafi.com"
    
    init(chatRoom: ChatRoom, userJID: String, userPassword: String) {
        self.chatRoom = chatRoom
        self.userJID = userJID
        self.userPassword = userPassword
        XMPPManager.shared.messageDelegate = self
        fetchPreviousMessages()
    }
    
    func extractNumberFromJID(_ jid: String) -> String? {
        if let range = jid.range(of: "@") {
            return String(jid[..<range.lowerBound])
        }
        return nil
    }
    
    func receivedMessage(from senderJID: XMPPJID, content: String) {
        let senderId = extractNumberFromJID(senderJID.full) ?? ""
        
        guard senderId != XMPPManager.shared.xmppStream.myJID?.user else {
            return
        }
        
        if let sender = SQLManager.shared.fetchUser(byId: senderId) {
            let receivedMsg = Message(id: UUID(), sender: sender, content: content, timestamp: Date())
            messages.append(receivedMsg)
            print(receivedMsg)
            if let chatRoom = self.chatRoom {
                _ = SQLManager.shared.storeMessage(message: receivedMsg, in: chatRoom)
            }
        } else {
            print("Failed to fetch user with id: \(senderId)")
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

    func fetchPreviousMessages() {
        if let chatRoom = self.chatRoom {
            let groupMessages = SQLManager.shared.fetchMessages(forChatRoomId: chatRoom.id) ?? []
            self.messages = groupMessages
            print("GROUD MESSAGES FOR \(chatRoom.displayName) ==================", groupMessages)
        }
    }
  
    
    func sendMessageToGroup(chatRoom: ChatRoom, content: String) {
        guard case let .group(_, participants) = chatRoom.type else {
            print("This function is for group messages only.")
            return
        }
        
        let participantJIDs = participants.map { $0.id }
        XMPPManager.shared.sendGroupMessage(to: participantJIDs, content: content, onSuccess: {
            if let currentUserJID = XMPPManager.shared.xmppStream.myJID?.user, let currentUser = SQLManager.shared.fetchUser(byId: currentUserJID) {
              
                let outgoingMsg = Message(id: UUID(), sender: currentUser, content: content, timestamp: Date())
                self.messages.append(outgoingMsg)

                // Store the sent message in the database
                if let chatRoom = self.chatRoom {
                    _ = SQLManager.shared.storeMessage(message: outgoingMsg, in: chatRoom)
                }
            } else {
                print("Failed to fetch current user for group message sending")
            }

        }, onFailure: { error in
            print("Error sending one or more messages: \(error)")
        })
    }


}
