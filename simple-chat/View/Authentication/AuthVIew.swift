//
//  AuthVIew.swift
//  simple-chat
//
//  Created by Imran Abdullah on 08/09/23.
//

import Foundation
import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var jid: String = ""
    @State private var password: String = ""
    
    
    var body: some View
        {
            NavigationView {
                VStack {
                    HStack {
                        Spacer(minLength: 0)
                        
                        Image("waafi_logo")
                            .resizable()
                            .scaledToFit()
                            .padding(.trailing)
                            .frame(width: 200, height: 200)
                        
                        Spacer(minLength: 0)
                    }
                    
                    Spacer(minLength: 0)
                    
                    Text("Join our app, enjoy chatting with your friends & family")
                        .font(.system(size: 25, weight: .heavy, design: .default))
                        .frame(width: (getRect().width * 0.9 ), alignment: .center)
                        .foregroundColor(Color("text"))
                        .padding(50)

                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .foregroundColor(Color.green)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(Color.red)
                    }
                    

                    Spacer(minLength: 0)
                    
                    VStack (alignment: .center, spacing: 5) {
                        HStack {
                            Spacer(minLength: 0)
                            
                            Image(systemName: "phone.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("ColorGreenMedium"))
                                .padding(.horizontal, 30)
                            
                            TextField("Enter your JID number", text: $jid)
                                .padding()
                                .border(Color.gray, width: 0.5)
                                .cornerRadius(25)
                            
                            Spacer(minLength: 0)
                            
                        }.overlay {
                            RoundedRectangle(cornerRadius: 36)
                                .stroke(Color.black, lineWidth: 1)
                                .opacity(0.3)
                                .frame(width: 320, height: 60, alignment: .center)
                        }
                        .padding()
                    
                        HStack {
                            Spacer(minLength: 0)
                            
                            Image(systemName: "lock.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("ColorGreenMedium"))
                                .padding(.horizontal, 30)
                            
                            SecureField("Enter password", text: $password)
                                .padding()
                                .border(Color.gray, width: 0.5)
                            
                            Spacer(minLength: 0)
                            
                        }.overlay {
                            RoundedRectangle(cornerRadius: 36)
                                .stroke(Color.black, lineWidth: 1)
                                .opacity(0.3)
                                .frame(width: 320, height: 60, alignment: .center)
                        }
                        .padding()
                        
                        

                    
                        Button(action: {
                            viewModel.authenticateUser(withJID: jid, password: password)
                                  }, label: {
                                      RoundedRectangle(cornerRadius: 36)
                                          .foregroundColor(Color("ColorGreenMedium"))
                                          .frame(width: 320, height: 60, alignment: .center)
                                          .overlay {
                                              Text(viewModel.isAuthenticating ? "Logging in..." : "Login")
                                                  .fontWeight(.bold)
                                                  .font(.title3)
                                                  .foregroundColor(Color.white)
                                                  .padding()
                                          }
                                  })
                        .disabled(viewModel.isAuthenticating)
                        
                    }
                    .padding()
                    
                    VStack (alignment: .center) {
                        VStack {
                            Text("By Signing up, you agree to our ")
                            + Text("Terms")
                                .foregroundColor(Color("text"))
                            + Text(", ")
                            + Text("Privacy Policy")
                                .foregroundColor(Color("text"))
                            + Text(", Cookie Use")
                                .foregroundColor(Color("text"))
                        }
                        .padding()
                        .frame(width: (getRect().width * 0.9 ), alignment: .center)
                        
                        
                        
                    }
                }
                .navigationBarHidden(true)
                .navigationBarTitle("")
            }
        }
}

