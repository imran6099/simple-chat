//
//  XMPPManager.swift
//  ios-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation
import XMPPFramework

class XMPPManager: NSObject, XMPPStreamDelegate, XMPPMUCDelegate {
    static let shared = XMPPManager()
    let muc = XMPPMUC(dispatchQueue: DispatchQueue.main)
    
    var xmppStream: XMPPStream!
    var messageDelegate: XMPPMessageDelegate?
    var inviteDelegate: XMPPInviteDelegate?
    weak var presenceDelegate: XMPPPresenceDelegate?
    
    private var userPassword: String?
    public var completion: ((Bool, XMPPServiceError?) -> Void)?
    
        var room: XMPPRoom?
        private let roomMemoryStorage = XMPPRoomMemoryStorage()
     
        private override init() {
            super.init()
            xmppStream = XMPPStream()
            xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
            
            muc.activate(xmppStream)
            muc.addDelegate(self, delegateQueue: DispatchQueue.main)
        }
      
      func connect(hostName: String, port: UInt16, username: String, password: String, completion: @escaping (Bool, XMPPServiceError?) -> Void) {
          
          if xmppStream.isConnected {
              completion(true, nil)
              return
          }

          self.completion = completion
          self.userPassword = password
          
          xmppStream.hostName = hostName
          xmppStream.hostPort = port
          xmppStream.myJID = XMPPJID(string: username)
          
          do {
              try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
          } catch {
              completion(false, .failedToConnect)
          }
      }
      
      func disconnect() {
          xmppStream.disconnect()
      }
    
    func xmppStreamDidConnect(_ stream: XMPPStream) {
        guard let password = userPassword else {
            completion?(false, .authenticationFailed)
            return
        }

        do {
            try stream.authenticate(withPassword: password)
        } catch {
            completion?(false, .authenticationFailed)
        }
    }
    
    func xmppStreamDidAuthenticate(_ stream: XMPPStream) {
        xmppStream.send(XMPPPresence())
    }
    
    
    func sendMessage(to recipientJID: String, content: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        let message = XMPPMessage(type: "chat", to: XMPPJID(string: recipientJID))
        message.addBody(content)
        
        if xmppStream.isConnected {
            xmppStream.send(message)
            onSuccess()
        } else {
            let error = NSError(domain: "XMPPService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to send the message."])
            onFailure(error)
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        if let msgStr = message.body, let from = message.from {
            messageDelegate?.receivedMessage(from: from, content: msgStr)
        }
    }
    
//    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
//            let userJID = presence.from
//            let isActive = presence.show == "available"
//            let lastActiveDate = Date() // This should be adjusted based on your XMPP server's behavior
//            guard let unwarappedUserJID = userJID else {
//                return
//            }
//            presenceDelegate?.receivedPresenceUpdate(from: unwarappedUserJID, isActive: isActive, lastActive: lastActiveDate)
//        }
    
    func sendGroupMessage(to recipientJIDs: [String], content: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        let group = DispatchGroup()
        var errors: [Error] = []
        
        for recipientJID in recipientJIDs {
            group.enter()
            
            sendMessage(to: "\(recipientJID)@uatchat2.waafi.com", content: content, onSuccess: {
                print("Sent to \(recipientJID)")
                group.leave()
            }, onFailure: { error in
                errors.append(error)
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                onSuccess()
            } else {
                let combinedError = NSError(domain: "XMPPService", code: -2, userInfo: [NSLocalizedDescriptionKey: "One or more messages failed to send."])
                onFailure(combinedError)
            }
        }
    }

    
    // Create a room
    func createRoom(withName roomName: String, userJID: String) -> Bool {
        guard let roomJID = XMPPJID(string: "\(roomName)@conference.servername") else {
            return false
        }
        guard let unwrappedRoomMemoryStorage = roomMemoryStorage else {
            print("Error: Room memory storage is nil")
            return false
        }
        let room = XMPPRoom(roomStorage: unwrappedRoomMemoryStorage, jid: roomJID, dispatchQueue: DispatchQueue.main)
        room.activate(xmppStream)
        room.addDelegate(self, delegateQueue: DispatchQueue.main)
        room.join(usingNickname: userJID, history: nil)
        
        print("STEP 2 ====== Room Created", room)
        
        return true
        
        
    }

    // Invite a user to the room
    func inviteUser(_ userJID: String, toRoom roomJID: XMPPJID, withNickname nickname: String, andMessage invitationMessage: String) {
        guard let inviteJID = XMPPJID(string: userJID) else { return }

        let message = XMPPMessage(type: "normal", to: roomJID)
        let inviteElement = XMLElement(name: "invite", xmlns: "uatchat2.waafi.com:5222")
        inviteElement.addAttribute(withName: "to", stringValue: inviteJID.full)

        if !invitationMessage.isEmpty {
            let reasonElement = XMLElement(name: "reason", stringValue: invitationMessage)
            inviteElement.addChild(reasonElement)
        }

        let xElement = XMLElement(name: "x", xmlns: "uatchat2.waafi.com:5222")
        xElement.addChild(inviteElement)
        message.addChild(xElement)
        
       
        
        xmppStream.send(message)
    }
    
    func sendStandardInvite(_ userJID: String, toRoom roomJID: XMPPJID, withReason reason: String?) {
        guard let inviteJID = XMPPJID(string: userJID) else { return }
        
        let message = XMPPMessage(type: "normal", to: roomJID)
        
        let xElement = XMLElement(name: "x", xmlns: "http://jabber.org/protocol/muc#user")
        let inviteElement = XMLElement(name: "invite")
        inviteElement.addAttribute(withName: "to", stringValue: inviteJID.full)
        
        if let reasonText = reason, !reasonText.isEmpty {
            let reasonElement = XMLElement(name: "reason", stringValue: reasonText)
            inviteElement.addChild(reasonElement)
        }
        
        xElement.addChild(inviteElement)
        message.addChild(xElement)
        
        print("STEP 3 ====== Sent Invitations", message)
        
        xmppStream.send(message)
    }

    
    func xmppMUC(_ sender: XMPPMUC, roomJID: XMPPJID, didReceiveInvitation message: XMPPMessage, userName: String) {
        // Handle the invitation. For example, present a notification to the user.
        let alert = UIAlertController(title: "Invitation", message: "You have been invited to join \(roomJID.user!)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { _ in
            // Join the room
            self.joinRoom(roomJID: roomJID, withNickname: userName)
        }))
        alert.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: nil))
    }
    
    func joinRoom(roomJID: XMPPJID, withNickname nickname: String) {
        guard let roomMemoryStorage = roomMemoryStorage else {
            print("Error: Room memory storage is nil")
            return
        }
        let room = XMPPRoom(roomStorage: roomMemoryStorage, jid: roomJID, dispatchQueue: DispatchQueue.main)
        room.activate(xmppStream)
        room.addDelegate(self, delegateQueue: DispatchQueue.main)
        room.join(usingNickname: nickname, history: nil)
    }
    
    func xmppRoomDidCreate(_ sender: XMPPRoom) {
        print("Room Created Successfully: \(sender.roomJID)")
    }
    
    func xmppRoomDidJoin(_ sender: XMPPRoom) {
        print("Successfully joined room: \(sender.roomJID)")
    }
        
    func xmppRoom(_ sender: XMPPRoom, didReceiveInvitation message: XMPPMessage) {
        print("Received invitation for room: \(sender.roomJID)")
    }
    

}

enum XMPPServiceError: Error {
    case wrongUserJID
    case failedToConnect
    case authenticationFailed
}

protocol XMPPMessageDelegate: AnyObject {
    func receivedMessage(from senderJID: XMPPJID, content: String)
}

protocol XMPPInviteDelegate: AnyObject {
    func receivedGroupInvitation(to roomJID: XMPPJID, from inviterJID: XMPPJID, reason: String)
}

protocol XMPPPresenceDelegate: AnyObject {
    func receivedPresenceUpdate(from userJID: XMPPJID, isActive: Bool, lastActive: Date)
}
