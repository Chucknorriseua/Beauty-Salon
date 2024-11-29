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
    @State private var loader: String = "Loader"
    @State private var isLoader: Bool = false
    @State private var messageAdmin: String = "Not correct password or email, it may be that this email is already in use"
    
    var body: some View {
        
            VStack {
                
                HStack(spacing: 10) {
                    
                    PhotosPicker(selection: $photoPickerItems, matching: .images) {
                        Image(uiImage: UIImage(data:  authMaster.selectedImage ?? Data() ) ?? UIImage(resource: .ab1))
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
                
                CustomTextField(text: $authMaster.signInViewmodel.phone,
                                title: "Phone(+000) ",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authMaster.signInViewmodel.showPassword)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .onChange(of: authMaster.signInViewmodel.phone) { _, new in
                    authMaster.signInViewmodel.phone = formatPhoneNumber(new)
                }
                
                CustomTextField(text: $authMaster.signInViewmodel.email,
                                title: "Email",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authMaster.signInViewmodel.showPassword)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                
                CustomTextField(text: $authMaster.signInViewmodel.password,
                                title: "Password",
                                width: UIScreen.main.bounds.width - 20,
                                showPassword: $authMaster.signInViewmodel.showPassword)
                
                CustomButton(title: "Register as Master") {
                    Task {
                  _ = await authMaster.saveAccount_Master()
                        coordinator.popToRoot()
                    }
    
                }.opacity(isFarmValid ? 1 : 0.5)
                .disabled(!isFarmValid)
                
                    .sheet(isPresented: $authMaster.isShowSheet) {
                        SheetStoreKitProductSelect(storeKitView: StoreViewModel.shared)
                        .presentationDetents([.height(320)])
                }
                
                VStack {
                    Button(action: {
                        coordinator.pop()
                        
                    }, label: {
                        Image(systemName: "arrow.left.to.line")
                        Text("Back to Sign In")
                    }).foregroundStyle((Color.white))
                      .font(.title2.bold())
                }
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
            .customAlert(isPresented: $authMaster.isShowAlert, message: messageAdmin, title: "Something went wrong", onConfirm: {}, onCancel: {})
            .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
    }
}
extension MasterRegister: isFormValid {
    var isFarmValid: Bool {
        return authMaster.signInViewmodel.email.contains("@gmail.com")
        && authMaster.signInViewmodel.password.count > 5
    }
    
    
}
