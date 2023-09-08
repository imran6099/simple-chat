//
//  MessageCell.swift
//  simple-chat
//
//  Created by Imran Abdullah on 08/09/23.
//

import Foundation
import SwiftUI

struct MessageCell: View {
    var message: Message
    @AppStorage("currentUserJID") var currentUserJID: String?
    
    @State private var isMessageTapped: Bool = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            if message.sender.id == currentUserJID! { // Message is from current user
                HStack {
                    Spacer() // Push content to the right
                    messageBubble(content: message.content, isCurrentUser: true)
                }
            } else { // Message is from other users
                HStack {
                    messageBubble(content: message.content, isCurrentUser: false)
                    Spacer() // Push content to the left
                }
            }
        }
        .padding([.leading, .trailing], 10)
        .onTapGesture {
            isMessageTapped.toggle()
        }
        .background(.white)
    }
    
    func messageBubble(content: String, isCurrentUser: Bool) -> some View {
        VStack {
            Text(content)
                .padding()
                .background(isCurrentUser ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(15)
            
            if isMessageTapped {
                Text(dateFormatter.string(from: message.timestamp))
                    .font(.footnote)
            }
        }
    }
}
