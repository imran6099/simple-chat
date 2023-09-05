//
//  simple_chatApp.swift
//  simple-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import SwiftUI

@main
struct simple_chatApp: App {
        @AppStorage("currentUserJID") var currentUserJID: String?
    
        init() {

            if let jid = currentUserJID {
                       let password = UserDefaults.standard.string(forKey: "currentUserPassword") ?? ""

                       XMPPManager.shared.connect(hostName: "uatchat2.waafi.com",
                                                  port: 5222,
                                                  username: jid,
                                                  password: password) { success, error in
                                                      if !success {
                                                          print("Failed to connect with error: \(error?.localizedDescription ?? "Unknown Error")")
                                                      }
                                                  }
                   }
            }
    
    var body: some Scene {
        WindowGroup {
            if currentUserJID == nil {
                LoginView()
            }
            else {
                ContactsListView()
            }
        }
    }
}
