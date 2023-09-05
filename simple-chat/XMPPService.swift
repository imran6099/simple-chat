////
////  XMPPService.swift
////  simple-chat
////
////  Created by Imran Abdullah on 05/09/23.
////
//
//import Foundation
//import XMPPFramework
//
//enum XMPPServiceError: Error {
//    case wrongUserJID
//    case failedToConnect
//    case authenticationFailed
//}
//
//class XMPPService: NSObject {
//    static let shared = XMPPService()
//    
//    var isXmppConnected: Bool = false
//    private var stream: XMPPStream!
//    private var userPassword: String?
//    var messageDelegate: XMPPMessageDelegate?
//    
//    public var completion: ((Bool, XMPPServiceError?) -> Void)?
//
//    private override init() {
//        super.init()
//        stream = XMPPStream()
//        stream.addDelegate(self, delegateQueue: DispatchQueue.main)
//    
//    }
//    
//    func connect(hostName: String, port: UInt16, username: String, password: String, completion: @escaping (Bool, XMPPServiceError?) -> Void) {
//        
//        if isXmppConnected {
//            completion(true, nil)
//            return
//        }
//
//        self.completion = completion
//        self.userPassword = password
//        
//        stream.hostName = hostName
//        stream.hostPort = port
//        stream.myJID = XMPPJID(string: username)
//        
//        do {
//            try stream.connect(withTimeout: XMPPStreamTimeoutNone)
//        } catch {
//            completion(false, .failedToConnect)
//        }
//    }
//    
//    func sendMessage(to recipientJID: String, content: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
//        print("Sending Message to \(recipientJID)")
//        let message = XMPPMessage(type: "chat", to: XMPPJID(string: recipientJID))
//        message.addBody(content)
//        
//        if stream.isConnected {
//            stream.send(message)
//            onSuccess()
//        } else {
//            let error = NSError(domain: "XMPPService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to send the message."])
//            onFailure(error)
//        }
//    }
//
//    
//    func disconnect() {
//        stream.disconnect()
//        isXmppConnected = false
//    }
//    
//
//}
//
//extension XMPPService: XMPPStreamDelegate, XMPPMessageDelegate {
//    func xmppStreamDidConnect(_ stream: XMPPStream) {
//        guard let password = userPassword else {
//            completion?(false, .authenticationFailed)
//            return
//        }
//
//        do {
//            try stream.authenticate(withPassword: password)
//        } catch {
//            completion?(false, .authenticationFailed)
//        }
//    }
//    
//    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
//        isXmppConnected = true
//        completion?(true, nil)
//    }
//        
//    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
//        completion?(false, .authenticationFailed)
//    }
//    
//    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
//        print("Message sent successfully!")
//    }
//
//    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
//        print("Failed to send message with error: \(error.localizedDescription)")
//    }
//    
//    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
//        if let msgStr = message.body, let from = message.from {
//            messageDelegate?.receivedMessage(from: from, content: msgStr)
//        }
//    }
//
//}
//
//protocol XMPPMessageDelegate {
//    func receivedMessage(from senderJID: XMPPJID, content: String)
//}
