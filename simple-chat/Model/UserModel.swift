//
//  UserModel.swift
//  simple-chat
//
//  Created by Imran Abdullah on 09/09/23.
//

import Foundation

struct User {
    let id: String
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
