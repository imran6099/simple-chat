////
////  TestCahtsView.swift
////  ios-chat
////
////  Created by Imran Abdullah on 05/09/23.
////
//
//import Foundation
//import SwiftUI
//
//struct TestChatListView: View {
//    @ObservedObject var viewModel = ChatViewModel()
//    
//    var body: some View {
//        VStack {
//            List(viewModel.messages, id: \.id) { message in
//                if message.sender.id == "900052318228" {
//                    Text("Me: \(message.content)")
//                } else {
//                    Text("Them: \(message.content)")
//                }
//            }
//            .onAppear {
//                viewModel.connect()
//                viewModel.loadMessages()
//            }
//            
//            SendMessageView(viewModel: viewModel)
//        }
//    }
//}
//
//struct SendMessageView: View {
//    @ObservedObject var viewModel: ChatViewModel
//    
//    @State private var message: String = ""
//    
//    var body: some View {
//        HStack {
//            TextField("Enter your message", text: $message)
//                .padding()
//            
//            Button(action: {
//                viewModel.sendMessage(message)
//                message = ""
//            }) {
//                Text("Send")
//                    .padding()
//            }
//        }
//    }
//}
//
//class ChatViewModel: ObservableObject, XMPPMessageDelegate {
//    @Published var messages: [Message] = []
//    
//    private var sqlService = SQLManager.shared
//    
//    init() {
//        XMPPManager.shared.messageDelegate = self
//    }
//    
//    func connect() {
//        XMPPManager.shared.connect(username: "900052318228@uatchat2.waafi.com", password: "YOUR PASSWORD HERE") { success in
//            if success {
//                print("Connected successfully")
//            } else {
//                print("Connection failed")
//            }
//        }
//    }
//    
//    func loadMessages() {
//        // Assuming you have an SQLService function to fetch all messages for a particular chat
//        self.messages = sqlService.fetchAllMessages(forChatId: /*Chat ID here*/)
//    }
//    
//    func sendMessage(_ content: String) {
//        let user = User(id: "900052318228", username: "Said", displayName: "", lastActive: Date(), isActive: true)
//        let message = Message(id: UUID(), sender: user, content: content, timestamp: Date())
//        
//        // Adjust the recipient's JID here
//        XMPPManager.shared.sendMessage(content, to: "900059931779@uatchat2.waafi.com")
//        messages.append(message)
//        
//        // Store this in SQLite database
//        sqlService.insertMessage(message, inChatId: /*Chat ID here*/)
//    }
//
//    func receivedMessage(content: String) {
//        let sender = User(id: "900059931779", username: "Abdullah", displayName: "", lastActive: Date(), isActive: true)
//        let message = Message(id: UUID(), sender: sender, content: content, timestamp: Date())
//        
//        DispatchQueue.main.async {
//            self.messages.append(message)
//            // Store this in SQLite database
//            self.sqlService.insertMessage(message, inChatId: /*Chat ID here*/)
//        }
//    }
//}
