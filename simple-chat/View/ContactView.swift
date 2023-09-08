//
//  ContactView.swift
//  simple-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation
import SwiftUI
import XMPPFramework

struct ContactsListView: View {
    @StateObject var viewModel = ContactsListViewModel()
    @AppStorage("currentUserJID") var currentUserJID: String?
    
    var body: some View {
        NavigationView {
            List {
                 // Section for Groups
                Section(header: Text("Group Chats")) {
                            ForEach(viewModel.groupChats.filter { groupChat in
                                groupChat.participants.contains(where: { $0.id == currentUserJID ?? "" })
                            }, id: \.id) { chat in
                                NavigationLink(destination: GroupChatView(chatRoom: chat)) {
                                    Text(chat.displayName)
                                }
                            }
                        }
                
                ForEach(viewModel.users.filter { $0.id != currentUserJID ?? "900052318228" }, id: \.id) { user in
                    NavigationLink(destination: ChatView(user: user)) {
                        Text(user.username)
                    }
                }
            }
            .navigationBarTitle("Chats", displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: CreateGroupChatView(viewModel: viewModel), isActive: $viewModel.isCreatingGroupChat) {
                              Button(action: {
                                  viewModel.isCreatingGroupChat.toggle()
                              }, label: {
                                  Image(systemName: "plus")
                              })
                          }
                      )
        }.alert(item: $viewModel.receivedInvitation) { chatRoom in
            Alert(
                title: Text("Group Chat Invitation"),
                message: Text("You've been invited to \(chatRoom.displayName). Would you like to join?"),
                primaryButton: .default(Text("Join")) {
                    // Handle joining the group chat here.
                    // e.g., self.joinRoom(chatRoom)
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            viewModel.fetchGroupChats()
        }
    }
}



class ContactsListViewModel: ObservableObject, XMPPMUCDelegate {
    @Published var users: [User] = SQLManager.shared.mockUsers
    @Published var groupChats: [ChatRoom] = []
    @Published var isCreatingGroupChat: Bool = false
    @Published var receivedInvitation: ChatRoom?
    
    init() {
        fetchGroupChats()
    }

    func fetchGroupChats() {
        self.groupChats = SQLManager.shared.fetchGroupChats()
    }
    
    func xmppMUC(_ sender: XMPPMUC, roomJID: XMPPJID, didReceiveInvitation message: XMPPMessage) {
        let chatRoom = ChatRoom(id: UUID(), messages: [], type: .group(name: roomJID.user!, participants: []))
        if  SQLManager.shared.storeChatRoom(chatRoom: chatRoom) {
            self.receivedInvitation = chatRoom
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.groupChats = SQLManager.shared.fetchGroupChats()
        }
        
        isCreatingGroupChat.toggle()
       
    }
    
}
