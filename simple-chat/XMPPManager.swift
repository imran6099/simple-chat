//
//  XMPPManager.swift
//  ios-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation
import XMPPFramework

class XMPPManager: NSObject, XMPPStreamDelegate {
    static let shared = XMPPManager()
    
    var xmppStream: XMPPStream!
    var messageDelegate: XMPPMessageDelegate?
    private var userPassword: String?
    public var completion: ((Bool, XMPPServiceError?) -> Void)?
    
    private override init() {
          super.init()
          xmppStream = XMPPStream()
          xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
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
        print("Sending Message to \(recipientJID)")
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

    
}

enum XMPPServiceError: Error {
    case wrongUserJID
    case failedToConnect
    case authenticationFailed
}

protocol XMPPMessageDelegate {
    func receivedMessage(from senderJID: XMPPJID, content: String)
}
