////
////  LoginViewModel.swift
////  simple-chat
////
////  Created by Imran Abdullah on 08/09/23.
////
//
//import Foundation
//import XMPPFramework
//
//class LoginViewModel: ObservableObject {
//    
//    private var xmppService: XMPPManager = XMPPManager.shared
//    
//    var currentUserJID = UserDefaults.standard.string(forKey: "currentUserJID") ?? ""
//    var userPassword = UserDefaults.standard.string(forKey: "userPassword") ?? ""
//
//   
//    let domain = "uatchat2.waafi.com"
//
//
//    func login(withJID jid: String, password: String) {
//        
//        let userJID = "\(jid)@\(domain)"
//        
//        xmppService.connect(hostName: domain, port: 5222, username: userJID, password: password) { [weak self] success, error in
//            if success {
//                self?.currentUserJID = jid
//                self?.userPassword = password
//                let presence = XMPPPresence()
//                XMPPManager.shared.xmppStream.send(presence)
//            } else {
//                print("Error logging in: \(error?.localizedDescription ?? "Unknown error")")
//            }
//        }
//    }
//}
