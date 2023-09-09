//
//  CustomAuthTextField.swift
//  simple-chat
//
//  Created by Imran Abdullah on 08/09/23.
//

import SwiftUI

struct CustomAuthTextField: View {
    
    var placeHolder: String
    @Binding var text: String
    
    var body: some View {
        VStack {
            ZStack (alignment: .leading) {
                if text.isEmpty {
                    Text(placeHolder)
                        .foregroundColor(.gray)
                }
                
                TextField("", text: $text)
                    .frame(height: 45)
                    .foregroundColor(Color("text"))

            }
        }
    }
}
