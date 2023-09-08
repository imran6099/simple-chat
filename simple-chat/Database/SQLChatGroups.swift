//
//  SQLChatGroups.swift
//  simple-chat
//
//  Created by Imran Abdullah on 07/09/23.
//

import Foundation
import SQLite

extension SQLManager {
    
    // Insert
    func insertGroupChat(chatRoom: ChatRoom) {
        guard case .group(let name, let participants) = chatRoom.type else {
            print("Only group chat can be inserted using this function.")
            return
        }

        // Insert the group chat into the chatRooms table
        do {
            let insert = chatRooms.insert(
                roomId <- chatRoom.id,
                chatType <- "group",
                participant1 <- nil,
                participant2 <- nil
            )
            try db!.run(insert)

            // Insert each participant of the group chat
            for user in participants {
                let insertParticipant = groupParticipants.insert(
                    self.roomId <- chatRoom.id,
                    id <- user.id,
                    groupName <- name
                )
                try db!.run(insertParticipant)
            }
        } catch {
            print("Error inserting mock group chat: \(error)")
        }
    }

    // Create group
    func createGroupChat(name: String, participants: [User]) -> ChatRoom? {
        // Store the chat room
        let roomId = UUID()
        let insert = chatRooms.insert(
            self.roomId <- roomId,
            chatType <- "group"
        )
        do {
            try db!.run(insert)
            // Store participants of the group
            for user in participants {
                let insertParticipant = groupParticipants.insert(
                    self.roomId <- roomId,
                    id <- user.id,
                    self.groupName <- name
                )
                try db!.run(insertParticipant)
            }
            return ChatRoom(id: roomId, messages: [], type: .group(name: name, participants: participants))
        } catch {
            print("Error creating group: \(error)")
            return nil
        }
    }
    
    func fetchGroupChats() -> [ChatRoom] {
        guard let db = SQLManager.shared.db else { return [] }

        do {
            let query = SQLManager.shared.chatRooms.filter(SQLManager.shared.chatType == "group")
            let rows = try db.prepare(query)

            var chatRooms: [ChatRoom] = []

            for row in rows {
                let roomId: UUID = row[SQLManager.shared.roomId]

                let participantsQuery = SQLManager.shared.groupParticipants.filter(SQLManager.shared.roomId == roomId)
                let participantsRows = try db.prepare(participantsQuery)

                var participants: [User] = []
                var groupName: String? = nil
                for participantRow in participantsRows {
                    if groupName == nil {
                        groupName = participantRow[SQLManager.shared.groupName]
                    }

                    let userId: String = participantRow[SQLManager.shared.id]
                    let userQuery = SQLManager.shared.users.filter(SQLManager.shared.id == userId).limit(1)

                    if let userRow = try db.pluck(userQuery) {
                        let fetchedUser = User(id: userRow[SQLManager.shared.id],
                                               username: userRow[SQLManager.shared.username],
                                               displayName: userRow[SQLManager.shared.displayName],
                                               lastActive: userRow[SQLManager.shared.lastActive],
                                               isActive: userRow[SQLManager.shared.isActive])
                        participants.append(fetchedUser)
                    }
                }

                if let groupName = groupName {
                    let chatRoom = ChatRoom(id: roomId, messages: [], type: .group(name: groupName, participants: participants))
                    chatRooms.append(chatRoom)
                }
            }

            return chatRooms

        } catch {
            print("Error fetching group chats: \(error)")
            return []
        }
    }

}
