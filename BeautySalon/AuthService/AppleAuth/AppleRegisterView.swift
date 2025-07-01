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
    @State private var isEditor: Bool = false
    @AppStorage("appleEmail") var appleEmail: String = ""
    @AppStorage("appleID") var appleID: String = ""
    
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 40) {
                Text("Selected Profile")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.yellow)
                    .multilineTextAlignment(.center)

                VStack(alignment: .center, spacing: 0) {
                    
                    Group {
                        VStack(alignment: .center) {
                            if selectedProfile == "Admin" {
            Text("Your administrator profile will be registered using Apple Sign-In. The data provided by Apple will be used to create your account and will complement the salon information you can enter in the profile settings. After registration, your salon will be created where you can enter additional information about your salon and add your masters to your salon.")
                            } else if selectedProfile == "Master" {
           Text("Your master profile will be registered using Apple Sign-In. The data provided by Apple will be used to create your account and will supplement the information about you that you can enter in your profile settings. Once registered, your profile will be created where you can enter additional information about yourself, add your work, and receive notes from administrators and customers.")
                                
                            } else if selectedProfile == "Client" {
            Text("Your customer profile will be registered using Apple Sign-In. The data provided by Apple will be used to create your account and supplement the information you can enter in your profile settings. Once registered, your profile will be created and you will be able to add additional information about yourself and update your name or phone number to contact you after sending the appointment to the salon or the master")
                            }
                        }
                        .font(.system(size: 18, weight: .heavy))
                        .fontDesign(.serif)
                        .foregroundStyle(Color.white)
                        .lineLimit(14)
                        .multilineTextAlignment(.leading)
                     
                    }.transition(.fade)
                        .padding(.top, 10)
                }
             
                Picker("Profile", selection: $selectedProfile) {
                    ForEach(profile, id: \.self) {
                        Text($0)
                            .fontWeight(.bold)
                    }
                }.pickerStyle(.palette)
                    .padding(.horizontal, 10)
                CustomButton(title: "Create") {
                    registerGoogle.rolePersone = selectedProfile
                    
                    Task {
                        try await registerGoogle.registerProfileWithGoogle(coordinator: coordinator, id: appleID)
                    }
                }
                
                .onAppear(perform: {
                    DispatchQueue.main.async {
                        registerGoogle.email = appleEmail
                    }
                })
                
                Button {
                    coordinator.push(page: .main)
                    appleID = ""
                    appleEmail = ""
                    selectedProfile = ""
                } label: {
                    Image(systemName: "arrow.left.to.line")
                    Text("Back to Sign In")
                }.foregroundStyle((Color.white))
                    .font(.title2.bold())
                Spacer()
            }
        }
        .createBackgrounfFon()
        .ignoresSafeArea(.keyboard)
    }
}
#Preview(body: {
    AppleRegisterView()
})
