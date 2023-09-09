//
//  ChatView.swift
//  simple-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation
import SwiftUI
import XMPPFramework

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            Text(viewModel.user.username)
                .font(.title2)
                .bold()
            
                      Text(viewModel.user.lastSeenStatus)
                          .font(.caption)
                          .foregroundColor(.gray)
     
            
            ScrollViewReader { proxy in
                List(viewModel.messages, id: \.id) { message in
                    MessageCell(message: message)
                        .id(message.id)
                }
                .onChange(of: viewModel.messages) { _ in
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("New message", text: $viewModel.newMessage)
                Button("Send", action: viewModel.sendMessage)
            }
            .padding()
        }
        .onAppear {
            viewModel.connectAndFetchMessages()
            viewModel.updateUserPresenceToActive() 
        }
    }
}
