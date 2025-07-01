//
//  AdminRegister.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI
import PhotosUI

struct AdminRegister: View {
    

    @EnvironmentObject var coordinator: CoordinatorView
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @StateObject var authViewModel = Auth_ADMIN_Viewmodel()
    @State private var show: Bool = false
    @State private var loader: String = "Loading"
    @State private var isLoader: Bool = false
    @State private var isPressAlarm: Bool = false
    @State private var messageAdmin: String = ""
    
    var body: some View {

            VStack {
                HStack {
                    
                    PhotosPicker(selection: $photoPickerItems, matching: .images) {
                        Image(uiImage: UIImage(data: authViewModel.selectedImage ?? Data() ) ?? UIImage(resource: .imageProfile))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    }
                    
                    Text("Сhoose photo salon")
                        .foregroundStyle(Color.white)
                        .font(.system(.title, design: .serif, weight: .regular))
                }
                
                
                CustomTextField(text: $authViewModel.signInViewModel.nameCompany,
                                title: "Salon name", width: UIScreen.main.bounds.width - 20,
                                showPassword: $authViewModel.signInViewModel.showPassword)
                
                CustomTextField(text: $authViewModel.signInViewModel.fullName,
                                title: "Name Administrator", width: UIScreen.main.bounds.width - 20,
                                showPassword:  $authViewModel.signInViewModel.showPassword)
                
                CustomTextFieldPhone(text: $authViewModel.signInViewModel.phone, title: "000-000-00-00",
                                     width: UIScreen.main.bounds.width - 20)
                
                CustomTextField(text: $authViewModel.signInViewModel.email,
                                title: "Email- @gmail", width: UIScreen.main.bounds.width - 20,
                                showPassword:  $authViewModel.signInViewModel.showPassword)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                
                CustomTextField(text: $authViewModel.signInViewModel.password,
                                title: "Password", width: UIScreen.main.bounds.width - 20,
                                showPassword:  $authViewModel.signInViewModel.showPassword)
                
                CustomButton(title: "Next") {
                    isLoader = true
                    Task {
                      let succec = await authViewModel.saveAdminCompany()
                      if succec {
                          coordinator.push(page: .Admin_Desc_Pass)
                            isLoader = false
                        } else {
                            isPressAlarm = true
                            messageAdmin = "Not correct password or email "
                        }
                    }
                }.opacity(isFarmValid ? 1 : 0.5)
 
                .disabled(!isFarmValid)
                
                VStack {
                    Button(action: {
                        coordinator.pop()
                        
                    }, label: {
                        Image(systemName: "arrow.left.to.line")
                        Text("Back to Sign In")
                    }).foregroundStyle((Color.white))
                      .font(.title2.bold())
                }.padding(.top, 30)
            }
            .onDisappear(perform: {
                authViewModel.signInViewModel.password = ""
            })
            .onChange(of: photoPickerItems) { _ , new in
                Task {
                    if let photoPickerItems,
                       let data = try? await photoPickerItems.loadTransferable(type: Data.self) {
                        if UIImage(data: data) != nil {
                            await MainActor.run {
                                authViewModel.selectedImage = data
                            }
                           
                        }
                    }
                    photoPickerItems = nil
                }
            }
            .createBackgrounfFon()
            .customAlert(isPresented: $isPressAlarm, hideCancel: false, message: messageAdmin, title: "Something went wrong", onConfirm: {}, onCancel: {})
            .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
    }
}

extension AdminRegister: isFormValid {
    var isFarmValid: Bool {
        return authViewModel.signInViewModel.email.contains("@gmail")
        && authViewModel.signInViewModel.password.count > 5
    }
}
