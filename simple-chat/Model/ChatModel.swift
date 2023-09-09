//
//  ChatModel.swift
//  simple-chat
//
//  Created by Imran Abdullah on 09/09/23.
//

import Foundation

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

