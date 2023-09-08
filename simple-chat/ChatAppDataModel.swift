//
//  ChatAppDataModel.swift
//  ios-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation

struct Message: Equatable {
    let id: UUID
    let sender: User
    let content: String
    let timestamp: Date
}

extension Message {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}


struct User {
    let id: String // XMPPJID
    let username: String
    let displayName: String
    var lastActive: Date
    var isActive: Bool
}

extension User {
    var lastSeenStatus: String {
        if isActive {
            return "Online"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return "Last seen: \(formatter.string(from: lastActive))"
        }
    }
}


enum ChatType {
    case oneOnOne(User)
    case group(name: String, participants: [User])
}

struct ChatRoom: Identifiable {
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
