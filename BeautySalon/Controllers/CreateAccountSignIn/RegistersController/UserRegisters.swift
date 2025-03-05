//
//  UserRegisters.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

struct UserRegisters: View {
    
    @StateObject var authClientViewModel = Auth_ClientViewModel()
    @EnvironmentObject  var coordinator: CoordinatorView
  
    @State private var loader: String = "Loading"
    @State private var isLoader: Bool = false

    @State private var isPressAlarm: Bool = false
    @State private var messageAdmin: String = ""
    
    var body: some View {

            VStack {
                CustomTextField(text: $authClientViewModel.signInViewmodel.fullName,
                                title: "Name",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authClientViewModel.signInViewmodel.showPassword)
                
                CustomTextFieldPhone(text: $authClientViewModel.signInViewmodel.phone, title: "000-000-00-00",
                                     width: .infinity)
                

                CustomTextField(text: $authClientViewModel.signInViewmodel.email,
                                title: "Email- @gmail",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authClientViewModel.signInViewmodel.showPassword)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                
                CustomTextField(text: $authClientViewModel.signInViewmodel.password,
                                title: "Password",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authClientViewModel.signInViewmodel.showPassword)
                
                CustomButton(title: "Create") {
                    isLoader = true
                    Task {
                        let succec =  await authClientViewModel.saveAccount_Master()
                        if succec {
                            coordinator.popToRoot()
                            isLoader = false
                        } else {
                           isPressAlarm = true
                            messageAdmin = "Not correct password or email "
                        }
                    }
                }

                .opacity(isFarmValid ? 1 : 0.5)
                    .disabled(!isFarmValid)
                
                
                VStack {
                    Button(action: {
                        coordinator.pop()
                        
                    }, label: {
                        Image(systemName: "arrow.left.to.line")
                        Text("Back to Sign In")
                    }).foregroundStyle((Color.white))
                      .font(.title2.bold())
                }
            }.onDisappear(perform: {
                authClientViewModel.signInViewmodel.password = ""
            })

            .createBackgrounfFon()
            .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
            .customAlert(isPresented: $isPressAlarm, hideCancel: false, message: messageAdmin, title: "Something went wrong", onConfirm: {}, onCancel: {})
    }
}


extension UserRegisters: isFormValid {
    var isFarmValid: Bool {
        return authClientViewModel.signInViewmodel.email.contains("@gmail")
        && authClientViewModel.signInViewmodel.password.count > 5
    }
    
    
}
