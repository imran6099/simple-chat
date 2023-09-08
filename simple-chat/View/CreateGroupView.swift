//
//  CreateGroupView.swift
//  simple-chat
//
//  Created by Imran Abdullah on 06/09/23.
//

import Foundation
import SwiftUI
import XMPPFramework

struct CreateGroupChatView: View {
    @State private var groupName: String = ""
    @State private var selectedUsers: [User] = []
    @AppStorage("currentUserJID") var currentUserJID: String?
    @StateObject var viewModel: ContactsListViewModel
    
    var body: some View {
        List {
            Section(header: Text("Group Name")) {
                TextField("Enter Group Name", text: $groupName)
            }
            
            Section(header: Text("Add Users")) {
                ForEach(viewModel.users.filter { $0.id != currentUserJID ?? "900052318228" }, id: \.id) { user in
                    Button(action: {
                        if selectedUsers.contains(where: { $0.id == user.id }) {
                            selectedUsers.removeAll { $0.id == user.id }
                        } else {
                            selectedUsers.append(user)
                        }
                    }) {
                        HStack {
                            Text(user.username)
                            Spacer()
                            if selectedUsers.contains(where: { $0.id == user.id }) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Section {
                Button("Create Group Chat") {
                    for user in selectedUsers {
                        XMPPManager.shared.sendStandardInvite(user.id, toRoom: XMPPJID(string: "\(groupName)@conference.servername")!, withReason: "You are invited to join \(groupName)")
                    }
                }
                .disabled(groupName.isEmpty || selectedUsers.isEmpty)

            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Create Group Chat")
    }
}


////
////  CreateGroupView.swift
////  simple-chat
////
////  Created by Imran Abdullah on 06/09/23.
////
//
//import Foundation
//import SwiftUI
//import XMPPFramework
//
//struct CreateGroupChatView: View {
//    @ObservedObject var viewModel = GroupChatCreationViewModel()
//    @AppStorage("currentUserJID") var currentUserJID: String?
//
//    var body: some View {
//        List(viewModel.users.filter { $0.id != currentUserJID ?? "900052318228" }, { user in
//            Button(action: {
//                viewModel.toggleUserSelection(user: user)
//            }) {
//                HStack {
//                    Text(user.name)
//                    Spacer()
//                    if viewModel.selectedUsers.contains(where: { $0.id == user.id }) {
//                        Image(systemName: "checkmark")
//                    }
//                }
//            }
//        }
//        VStack {
//            TextField("Group Name", text: $viewModel.groupName)
//            Button("Create Group") {
//                viewModel.createGroupChat()
//            }
//        }
//    }
//}
//
//class GroupChatCreationViewModel: ObservableObject {
//    @Published var users: [User] = SQLManager.shared.mockUsers
//    @Published var groupName: String = ""
//    @Published var selectedUsers: [User] = []
//    let domain = "uatchat2.waafi.com"
//    let userJID = UserDefaults.standard.string(forKey: "currentUserJID") ?? "defaultJID"
//
//    func createGroupChat() {
//        // First, create the chat room in the local database
//        let chatRoom = ChatRoom(id: UUID(), messages: [], type: .group(name: groupName, participants: selectedUsers))
//        if SQLManager.shared.storeChatRoom(chatRoom: chatRoom) {
//            // If successful, then create it in XMPP and invite participants
//            XMPPManager.shared.createRoom(withName: groupName, userJID: userJID)
//
//            for user in selectedUsers {
//                XMPPManager.shared.inviteUser(user.id, toRoom: XMPPJID(string: "\(groupName)@conference.servername")!, withNickname: user.username, andMessage: "You are invited to join \(groupName)")
//            }
//        }
//    }
//
//    func toggleUserSelection(user: User) {
//        if let index = selectedUsers.firstIndex(where: { $0.id == user.id }) {
//            selectedUsers.remove(at: index)
//        } else {
//            selectedUsers.append(user)
//        }
//    }
//}
//
