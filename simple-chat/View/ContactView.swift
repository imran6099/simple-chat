//
//  ContactView.swift
//  simple-chat
//
//  Created by Imran Abdullah on 05/09/23.
//

import Foundation
import SwiftUI

struct ContactsListView: View {
    @StateObject var viewModel = ContactsListViewModel()
    @AppStorage("currentUserJID") var currentUserJID: String?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.users.filter { $0.id != currentUserJID ?? "900052318228" }, id: \.id) { user in
                    NavigationLink(destination: ChatView(user: user)) {
                        Text(user.username)
                    }
                }
            }
            .navigationBarTitle("Chats", displayMode: .inline)
        }
    }
}



class ContactsListViewModel: ObservableObject {
    @Published var users: [User] = SQLManager.shared.mockUsers

}
