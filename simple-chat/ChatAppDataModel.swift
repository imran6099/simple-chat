//
//  ChatAppDataModel.swift
//  ios-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation

struct Message {
    let id: UUID
    let sender: User
    let content: String
    let timestamp: Date
}

struct User {
    let id: String // XMPPJID
    let username: String
    let displayName: String
    let lastActive: Date
    let isActive: Bool
}

enum ChatType {
    case oneOnOne(User)
    case group(name: String, participants: [User])
}

struct ChatRoom {
    let id: UUID
    var messages: [Message]
    let type: ChatType
    
    // Convenience property to get participants
    var participants: [User] {
        switch type {
        case .oneOnOne(let user):
            return [user]
        case .group(_, let participants):
            return participants
        }
    }
    
   
    var displayName: String {
        switch type {
        case .oneOnOne(let user):
            return user.displayName
        case .group(let name, _):
            return name
        }
    }
}
