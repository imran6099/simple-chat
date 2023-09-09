//
//  MessageModel.swift
//  simple-chat
//
//  Created by Imran Abdullah on 09/09/23.
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
