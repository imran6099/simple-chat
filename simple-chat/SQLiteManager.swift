//
//  SQLiteManager.swift
//  ios-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation
import SQLite

class SQLManager {
    static let shared = SQLManager()
    internal var db: Connection?
    
    // Table User
    let users = Table("users")
    let id = Expression<String>("id") // XMPPJID
    let username = Expression<String>("username")
    let displayName = Expression<String>("displayName")
    let lastActive = Expression<Date>("lastActive")
    let isActive = Expression<Bool>("isActive")
    
    // Messages
    let messages = Table("messages")
    let messageId = Expression<UUID>("messageId")
    let messageSender = Expression<String>("sender") // This will be XMPPJID
    let content = Expression<String>("content")
    let timestamp = Expression<Date>("timestamp")
    let chatRoomId = Expression<UUID>("chatRoomId") // Foreign key
    
    // Chat Rooms
    let chatRooms = Table("chatRooms")
    let roomId = Expression<UUID>("roomId")
    let chatType = Expression<String>("type") // Either "oneOnOne" or "group"
    let participant1 = Expression<String?>("participant1")
    let participant2 = Expression<String?>("participant2")
    
    // Group Chats
    let groupParticipants = Table("groupParticipants")
    let groupName = Expression<String>("groupName")
    
    private init() {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            do {
                db = try Connection("\(path)/db.sqlite3")
                try db!.execute("PRAGMA foreign_keys = ON")
                
                createTableUsers()
                createTableMessages()
                createTableChatRooms()
                createTableGroupParticipants()
                
                seedDatabaseIfEmpty()
                
            } catch {
                db = nil
                print("Unable to open database: \(error)")
            }
        }
        
        // Create Users Table
        func createTableUsers() {
            do {
                try db!.run(users.create(ifNotExists: true) { table in
                    table.column(id, primaryKey: true)
                    table.column(username)
                    table.column(displayName)
                    table.column(lastActive)
                    table.column(isActive)
                })
            } catch {
                print("Unable to create users table: \(error)")
            }
        }
        
        // Create Messages Table
        func createTableMessages() {
            do {
                try db!.run(messages.create(ifNotExists: true) { table in
                    table.column(messageId, primaryKey: true)
                    table.column(messageSender)
                    table.column(content)
                    table.column(timestamp)
                    table.column(chatRoomId)
                })
            } catch {
                print("Unable to create messages table: \(error)")
            }
        }
        
        // Create Chat Rooms Table
        func createTableChatRooms() {
            do {
                try db!.run(chatRooms.create(ifNotExists: true) { table in
                    table.column(roomId, primaryKey: true)
                    table.column(chatType)
                    table.column(participant1)
                    table.column(participant2)
                })
            } catch {
                print("Unable to create chatRooms table: \(error)")
            }
        }
        
        // Create Group Participants Table
        func createTableGroupParticipants() {
            do {
                try db!.run(groupParticipants.create(ifNotExists: true) { table in
                    table.column(roomId) // Foreign key
                    table.column(id)     // Foreign key
                    table.column(groupName)
                    table.primaryKey(roomId, id)
                })
            } catch {
                print("Unable to create groupParticipants table: \(error)")
            }
        }
    
    func insertUser(user: User) {
           do {
               let insert = users.insert(id <- user.id,
                                         username <- user.username,
                                         displayName <- user.displayName,
                                         lastActive <- user.lastActive,
                                         isActive <- user.isActive)
               try db!.run(insert)
           } catch {
               print("Insert failed: \(error)")
           }
       }
       
       // Seed User
       func seedDatabaseIfEmpty() {
           do {
               let userCount = try db!.scalar(users.count)
               if userCount == 0 {
                   let mockUsers: [User] = [
                       User(id: "900052318228", username: "Said", displayName: "", lastActive: Date(), isActive: false),
                       User(id: "900059931779", username: "Abdullah", displayName: "", lastActive: Date(), isActive: false),
                       User(id: "900087689251", username: "Yuusuf", displayName: "", lastActive: Date(), isActive: false),
                       User(id: "900116482631", username: "Mohamed", displayName: "", lastActive: Date(), isActive: false)
                   ]
                   
                   for user in mockUsers {
                       insertUser(user: user)
                   }
               }
           } catch {
               print("Failed to seed database: \(error)")
           }
     }
    
    let mockUsers: [User] = [
        User(id: "900052318228", username: "Said", displayName: "", lastActive: Date(), isActive: false),
        User(id: "900059931779", username: "Abdullah", displayName: "", lastActive: Date(), isActive: false),
        User(id: "900087689251", username: "Yuusuf", displayName: "", lastActive: Date(), isActive: false),
        User(id: "900116482631", username: "Mohamed", displayName: "", lastActive: Date(), isActive: false)
    ]
    
    func fetchUser(byId userId: String) -> User? {
        let query = users.filter(self.id == userId)
        do {
            if let row = try db!.pluck(query) {
                return User(id: row[id],
                            username: row[username],
                            displayName: row[displayName],
                            lastActive: row[lastActive],
                            isActive: row[isActive])
            }
        } catch {
            print("Fetch user by ID failed: \(error)")
        }
        return nil
    }

    func fetchChatRoom(byId roomId: UUID) -> ChatRoom? {
        let query = chatRooms.filter(self.roomId == roomId)
        
        do {
            if let row = try db!.pluck(query) {
                let chatTypeStr = row[chatType]
                var chatType: ChatType?
                
                switch chatTypeStr {
                case "oneOnOne":
                    if let user = fetchUser(byId: row[id]) {  // Assuming the 'id' in the chatRooms table is the user ID for oneOnOne chats.
                        chatType = .oneOnOne(user)
                    }
                    
                case "group":
                    let groupQuery = groupParticipants.filter(self.roomId == roomId)
                    var participants: [User] = []
                    for participantRow in try db!.prepare(groupQuery) {
                        if let user = fetchUser(byId: participantRow[id]) {
                            participants.append(user)
                        }
                    }
                    let groupName = participants.first?.displayName ?? ""
                    chatType = .group(name: groupName, participants: participants)
                    
                default:
                    print("Unknown chat type: \(chatTypeStr)")
                }
                
                if let chatType = chatType {
                    // Fetch messages related to the chat room
                    let messagesQuery = messages.filter(self.chatRoomId == roomId)
                    var chatMessages: [Message] = []
                    
                    for messageRow in try db!.prepare(messagesQuery) {
                        if let senderUser = fetchUser(byId: messageRow[messageSender]) {
                            let message = Message(
                                id: messageRow[messageId],
                                sender: senderUser,
                                content: messageRow[content],
                                timestamp: messageRow[timestamp]
                            )
                            chatMessages.append(message)
                        } else {
                            print("Failed to find sender for message: \(messageRow[messageId])")
                        }
                    }
                    
                    return ChatRoom(id: roomId, messages: chatMessages, type: chatType)
                }
            }
        } catch {
            print("Fetch chat room by ID failed: \(error)")
        }
        
        return nil
    }
    
    // Get chat with user id
    func fetchChatRoom(participant1Id: String) -> ChatRoom? {
        let query = chatRooms.filter(self.participant1 == participant1Id)
        
        do {
            print("Fetching chat room based on participant1 id \(participant1Id)")
            
            for row in try! db!.prepare(chatRooms) {
                print(row)
            }
            
            if let row = try db!.pluck(query) {
                return chatRoom(from: row)
            } else {
                print("didn't find chat room for participant1 id \(participant1Id)")
            }
        } catch {
            print("Fetch chat room by participant1 failed: \(error)")
        }
        
        return nil
    }

    private func chatRoom(from row: Row) -> ChatRoom? {
        print("Found Row \(row)")

        let chatTypeStr = row[chatType]
        var chatType: ChatType?

        switch chatTypeStr {
        case "oneOnOne":
            if let user = fetchUser(byId: row[participant1]!) {
                chatType = .oneOnOne(user)
            }
        default:
            print("Unknown chat type: \(chatTypeStr)")
            return nil
        }
        
        let roomIdValue = row[roomId]
        
        // Fetch messages for the chat room
        let messagesQuery = messages.filter(self.chatRoomId == roomIdValue)
        var chatMessages: [Message] = []

        for messageRow in try! db!.prepare(messagesQuery) {
            if let senderUser = fetchUser(byId: messageRow[messageSender]) {
                let message = Message(
                    id: messageRow[messageId],
                    sender: senderUser,
                    content: messageRow[content],
                    timestamp: messageRow[timestamp]
                )
                chatMessages.append(message)
            } else {
                print("Failed to find sender for message: \(messageRow[messageId])")
            }
        }
        
        print("Found Chat Messages \(chatMessages)")
        
        return ChatRoom(id: roomIdValue, messages: chatMessages, type: chatType!)
    }


    func storeChatRoom(chatRoom: ChatRoom) -> Bool {
        do {
            // Store based on chat type
            switch chatRoom.type {
            case .oneOnOne(let user):
                let insert = chatRooms.insert(
                    roomId <- chatRoom.id,
                    chatType <- "oneOnOne",
                    participant1 <- user.id,
                    participant2 <- nil // This can be null for oneOnOne chat
                )
                try db!.run(insert)
                
            case .group(let name, let participants):
                // Insert chat room first
                let insertChatRoom = chatRooms.insert(
                    roomId <- chatRoom.id,
                    chatType <- "group",
                    participant1 <- nil,
                    participant2 <- nil
                )
                try db!.run(insertChatRoom)
                
                // Then, store each participant for the group chat room
                for user in participants {
                    let insertParticipant = groupParticipants.insert(
                        roomId <- chatRoom.id,
                        id <- user.id,
                        groupName <- name
                    )
                    try db!.run(insertParticipant)
                }
            }
            return true
            
        } catch {
            print("Store chat room failed: \(error)")
            return false
        }
    }

    
    func storeMessage(message: Message, in chatRoom: ChatRoom) -> Bool {
        do {
            let insert = messages.insert(
                messageId <- message.id,
                messageSender <- message.sender.id,
                content <- message.content,
                timestamp <- message.timestamp,
                chatRoomId <- chatRoom.id
            )
            try db!.run(insert)
            return true
            
        } catch {
            print("Store message failed: \(error)")
            return false
        }
    }
    
    func fetchMessages(forChatRoomId roomId: UUID) -> [Message]? {
        var resultMessages: [Message] = []

        // Prepare the query for the messages table
        let query = messages.filter(self.chatRoomId == roomId)

        do {
            for messageRow in try db!.prepare(query) {
                if let senderUser = fetchUser(byId: messageRow[messageSender]) {
                    let message = Message(
                        id: messageRow[messageId],
                        sender: senderUser,
                        content: messageRow[content],
                        timestamp: messageRow[timestamp]
                    )
                    resultMessages.append(message)
                } else {
                    print("Failed to find sender for message: \(messageRow[messageId])")
                }
            }
            return resultMessages
        } catch {
            print("Fetch messages for chat room by ID failed: \(error)")
            return nil
        }
    }


}
