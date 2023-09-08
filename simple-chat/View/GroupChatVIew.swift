//
//  GroupChatVIew.swift
//  simple-chat
//
//  Created by Imran Abdullah on 06/09/23.
//

import Foundation
import SwiftUI
import XMPPFramework 

struct GroupChatView: View {
    @ObservedObject var viewModel: GroupChatViewModel
    @State private var inputMessage: String = ""
    let domain = "uatchat2.waafi.com"

    let currentUserJID = UserDefaults.standard.string(forKey: "currentUserJID") ?? ""
    let userPassword = UserDefaults.standard.string(forKey: "userPassword") ?? ""
    
    init(chatRoom: ChatRoom) {
        viewModel = GroupChatViewModel(chatRoom: chatRoom, userJID: currentUserJID, userPassword: userPassword)
    }

    var body: some View {
        VStack {
        
            
            ScrollView {
                ForEach(viewModel.messages, id: \.id) { message in
                    HStack {
                        if message.sender.id == viewModel.userJID {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(message.sender.username)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        } else {
                            VStack(alignment: .leading) {
                                Text(message.sender.username) 
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(15)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }

            }
            
            HStack {
                           TextField("Enter your message...", text: $inputMessage)
                               .textFieldStyle(RoundedBorderTextFieldStyle())
                               .padding(8)
                           
                           Button(action: {
                               if !inputMessage.isEmpty {
                                   viewModel.sendMessageToGroup(chatRoom: viewModel.chatRoom!, content: inputMessage)
                                   inputMessage = ""
                               }
                           }) {
                               Image(systemName: "paperplane.fill")
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 24, height: 24)
                                   .padding(8)
                           }
                       }
                       .padding(.horizontal)
            
        }
        .navigationBarTitle(viewModel.chatRoom?.displayName ?? "Chat Group", displayMode: .inline)
        .onAppear {
            viewModel.connectAndFetchMessages()
        }

    }
}

