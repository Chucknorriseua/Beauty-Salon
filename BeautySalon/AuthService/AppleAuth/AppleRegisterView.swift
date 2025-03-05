//
//  AppleRegisterView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 26/02/2025.
//

import SwiftUI

struct AppleRegisterView: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var apple: AppleAuthViewModel
    @StateObject var registerGoogle = SignInViewModel()
    @State private var profile = ["Admin", "Master", "Client"]
    @State private var selectedProfile = "Admin"
    @AppStorage ("appleEmail") var appleEmail: String = ""
    @AppStorage ("appleID") var appleID: String = ""
 
    
    var body: some View {
        
        VStack {
            Text("Selected Profile")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.yellow)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .center, spacing: 10) {
                Picker("Profile", selection: $selectedProfile) {
                    ForEach(profile, id: \.self) {
                        Text($0)
                    }
                }.pickerStyle(.segmented)
                
                Group {
                    
                    if selectedProfile == "Admin" {
                        CustomTextField(text: $registerGoogle.fullName, title: "Name", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword)
                        CustomTextField(text: $registerGoogle.nameCompany, title: "Name Company", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword)
                        CustomTextFieldPhone(text: $registerGoogle.phone, title: "000-000-00-00",
                                             width: UIScreen.main.bounds.width - 20)
                        CustomTextField(text: Binding(get: {appleEmail}, set: { newvalue in appleEmail = newvalue }), title: "Email", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword).disabled(true)
                        
                    } else if selectedProfile == "Master" || selectedProfile == "Client" {
                        CustomTextField(text: $registerGoogle.fullName, title: "Name", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword)
                        CustomTextFieldPhone(text: $registerGoogle.phone, title: "000-000-00-00",
                                             width: UIScreen.main.bounds.width - 20)
                        CustomTextField(text: Binding(get: {appleEmail}, set: { newvalue in appleEmail = newvalue }), title: "Email", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword).disabled(true)
                        
                    }
                }.transition(.fade)
            }
            .padding()
            
            CustomButton(title: "Create") {
                registerGoogle.rolePersone = selectedProfile
                
                Task {
                    try await registerGoogle.registerProfileWithGoogle(coordinator: coordinator, id: appleID)
//                    google.isLogin = false
                }
            }
            .onAppear(perform: {
                DispatchQueue.main.async {
                    registerGoogle.email = appleEmail
                }
            })
  
            Button {
//                google.isLogin = false
                coordinator.popToRoot()
            } label: {
                Image(systemName: "arrow.left.to.line")
                Text("Back to Sign In")
            }.foregroundStyle((Color.white))
                .font(.title2.bold())
            
        }
        .createBackgrounfFon()
        
    }
}

