//
//  GoogleRegisterProfile.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/10/2024.
//

import SwiftUI


struct GoogleRegisterProfile: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    @StateObject var registerGoogle = SignInViewModel()
    @State private var profile = ["Admin", "Master", "Client"]
    @State private var selectedProfile = "Admin"
 
    
    var body: some View {
        
        VStack {
            Text("Selected Profile")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.yellow.opacity(0.8))
            
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
                        CustomTextField(text: $registerGoogle.phone, title: "Phone (+000)", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                        CustomTextField(text: Binding(get: {google.emailGoogle ?? ""}, set: { newvalue in google.emailGoogle = newvalue }), title: "Email", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword).disabled(true)
                        
                    } else if selectedProfile == "Master" || selectedProfile == "Client" {
                        CustomTextField(text: $registerGoogle.fullName, title: "Name", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword)
                        CustomTextField(text: $registerGoogle.phone, title: "Phone (+000)", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                        CustomTextField(text: Binding(get: {google.emailGoogle ?? ""}, set: { newvalue in google.emailGoogle = newvalue }), title: "Email", width: UIScreen.main.bounds.width - 20, showPassword: $registerGoogle.showPassword).disabled(true)
                        
                    }
                }.transition(.fade)
                .onChange(of: registerGoogle.phone) { _, new in
                        registerGoogle.phone = formatPhoneNumber(new)
                    }
            }
            .padding()
            
            CustomButton(title: "Create") {
                registerGoogle.rolePersone = selectedProfile
                
                Task {
                    try await registerGoogle.registerProfileWithGoogle(coordinator: coordinator, id: google.idGoogle)
                    google.isLogin = false
                }
            }
            .onAppear(perform: {
                registerGoogle.email = google.emailGoogle ?? ""
            })
  
            Button {
                google.isLogin = false
                coordinator.popToRoot()
            } label: {
                Image(systemName: "arrow.left.to.line")
                Text("Back to Sign In")
            }.foregroundStyle((Color.white))
                .font(.title2.bold())
            
        }
        .navigationBarTitleDisplayMode(.inline).toolbar {
            ToolbarItem(placement: .principal) {
                Text("Register Profile with Google")
                    .foregroundStyle(Color.yellow.opacity(0.8))
                    .font(.system(size: 26, weight: .heavy).bold())
            }
        }
        .createBackgrounfFon()
        
    }
}
