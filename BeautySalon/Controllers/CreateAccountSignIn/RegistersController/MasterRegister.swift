//
//  MasterRegister.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI
import PhotosUI

struct MasterRegister: View {

    @StateObject var authMaster = Auth_Master_ViewModel()
    @EnvironmentObject var coordinator: CoordinatorView
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @State private var loader: String = "Loading"
    @State private var isLoader: Bool = false
    @State private var messageAdmin: String = "Not correct password or email, it may be that this email is already in use"
    
    var body: some View {
        
            VStack {
                
                HStack(spacing: 10) {
                    
                    PhotosPicker(selection: $photoPickerItems, matching: .images) {
                        Image(uiImage: UIImage(data:  authMaster.selectedImage ?? Data() ) ?? UIImage(resource: .imageProfile))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    }
                    
                    Text("Сhoose your photo profile")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 20, weight: .heavy))
                }
                
                CustomTextField(text: $authMaster.signInViewmodel.fullName,
                                title: "Name",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authMaster.signInViewmodel.showPassword)
                
                CustomTextFieldPhone(text: $authMaster.signInViewmodel.phone, title: "000-000-00-00",
                                     width: UIScreen.main.bounds.width - 20)
                
                CustomTextField(text: $authMaster.signInViewmodel.email,
                                title: "Email- @gmail",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authMaster.signInViewmodel.showPassword)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                
                CustomTextField(text: $authMaster.signInViewmodel.password,
                                title: "Password",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authMaster.signInViewmodel.showPassword)
                
                CustomButton(title: "Create") {
                    Task {
                  _ = await authMaster.saveAccount_Master()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoader = false
                            coordinator.push(page: .Master_Select_Company)
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
                }
                .padding(.top, 30)
            }
            .onDisappear(perform: {
                authMaster.signInViewmodel.password = ""
          })
        .onChange(of: photoPickerItems ) {_, new in
                Task {
                    if let photoPickerItems,
                       let data = try? await photoPickerItems.loadTransferable(type: Data.self) {
                        if UIImage(data: data) != nil {
                            await MainActor.run {
                                authMaster.selectedImage = data
                            }
                           
                        }
                    }
                    photoPickerItems = nil
                }
            }
            .createBackgrounfFon()
            .customAlert(isPresented: $authMaster.isShowAlert, hideCancel: false, message: messageAdmin, title: "Something went wrong", onConfirm: {}, onCancel: {})
            .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
    }
}
extension MasterRegister: isFormValid {
    var isFarmValid: Bool {
        return authMaster.signInViewmodel.email.contains("@gmail")
        && authMaster.signInViewmodel.password.count > 5
    }
    
    
}
