//
//  AuthViewModel.swift
//  simple-chat
//
//  Created by Imran Abdullah on 08/09/23.
//

import Foundation
class AuthViewModel: ObservableObject {
    
    var userJID = UserDefaults.standard.string(forKey: "currentUserJID") ?? "defaultJID"
    var userPassword = UserDefaults.standard.string(forKey: "userPassword") ?? ""
    let domain = "uatchat2.waafi.com"
    
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    @Published var isAuthenticating = false
    
    
     func authenticateUser(withJID jid: String, password: String) {
        isAuthenticating = true
        let userJID = "\(jid)@\(domain)"
        
         XMPPManager.shared.connect(hostName: domain, port: 5222, username: userJID, password: password) { success, error in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    // Store current user in AppStorage
                   
                    self.userJID = jid
                    self.userPassword = password
            
                    self.errorMessage = nil
                    self.successMessage = "Welcome"
                } else {
                    self.isAuthenticating = false
                    switch error {
                    case .wrongUserJID:
                        self.errorMessage = "Invalid JID"
                    case .failedToConnect:
                        self.errorMessage = "Failed to connect. Please try again."
                        XMPPManager.shared.disconnect()
                    case .authenticationFailed:
                        self.errorMessage = "Authentication failed. Check your number and password."
                        XMPPManager.shared.disconnect()
                    default:
                        self.errorMessage = "An unknown error occurred. Please try again."
                        XMPPManager.shared.disconnect()
                    }
                }
            }
        }
    }
    
    
    
}
