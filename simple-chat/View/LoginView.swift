//
//  LoginView.swift
//  simple-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    @State private var jid: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter your JID number", text: $jid)
                .padding()
                .border(Color.gray, width: 0.5)
            
            SecureField("Enter password", text: $password)
                .padding()
                .border(Color.gray, width: 0.5)
            
            Button(action: {
                viewModel.login(withJID: jid, password: password)
            }) {
                Text("Login")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

class LoginViewModel: ObservableObject {
    
    private var xmppService: XMPPManager = XMPPManager.shared

    @AppStorage("currentUserJID") var currentUserJID: String?
    @AppStorage("userPassword") var userPassword: String?
    
    let domain = "uatchat2.waafi.com"


    func login(withJID jid: String, password: String) {
        
        let userJID = "\(jid)@\(domain)"
        
        xmppService.connect(hostName: domain, port: 5222, username: userJID, password: password) { [weak self] success, error in
            if success {
                self?.currentUserJID = jid
                self?.userPassword = password
            } else {
                print("Error logging in: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
