//
//  SettingsMasterController.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 11/02/2025.
//

import SwiftUI
import PhotosUI

struct SettingsMasterController: View {
    
    @State private var isShowDesc: Bool = false
    @StateObject var authViewModel = Auth_Master_ViewModel()
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    @ObservedObject var masterViewModel: MasterViewModel

    
    @AppStorage ("selectedAdmin") private var selectedAdminID: String?
    @AppStorage ("useRole") private var useRole: String = ""
    
    @State private var isPressAlarm: Bool = false
    @State private var isShowprofilephoto: Bool = false
    @State private var isEditor: Bool = false
    @State private var isChangeProfilePhoto: Bool = false
    
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @Binding  var isPressFullScreen: Bool
    @State var selectedImage: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                Group {
                    VStack(spacing: 30) {
                        HStack(spacing: 14) {
                            
                            VStack {}
                                .createImageView(model: masterViewModel.masterModel.image ?? "", width: 120, height: 120)
                            
                            VStack(spacing: 0) {
                                Text(masterViewModel.masterModel.name)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .lineLimit(4)
                                    .frame(maxWidth: 140, maxHeight: 50)
                            }
                            
                            Spacer()
                        }
                        .padding(.leading, 14)
                        
                        HStack {
                            SettingsPhotoView(masterViewModel: masterViewModel, selectedImage: $selectedImage, isPressFullScreen: $isPressFullScreen, isShowPhotoPicker: $isShowprofilephoto)
                        }
                        
                        if isShowDesc {
                            VStack {
                                SettingsTextField(text: $masterViewModel.masterModel.name, title: "Name", width: .infinity)
                                SettingsTextFieldPhone(text: $masterViewModel.masterModel.phone, title: "Phone +(000)", width: .infinity)
                               
                            }
                            ZStack(alignment: .topLeading) {
                                if masterViewModel.masterModel.description.isEmpty {
                                    Text("Please limit your input to 160 characters.")
                                        .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                TextEditor(text: $masterViewModel.masterModel.description)
                                    .scrollContentBackground(.hidden)
                                    .foregroundStyle(Color.white)
                            }.frame(height: 160, alignment: .leading)
                                .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                .clipShape(.rect(cornerRadius: 16))
                                .padding(.horizontal, 12)
                            CustomSettingsButton(title: "Back") {
                                withAnimation(.linear) {
                                    isShowDesc.toggle()
                                }
                            }
                        } else {
                            CustomSettingsButton(title: "Change profile photo") {
                                isChangeProfilePhoto = true
                            }
                            CustomSettingsButton(title: "Upload photos of my work") {
                                isShowprofilephoto = true
                            }
                            
                            CustomSettingsButton(title: "Monthly statistics") {
                                coordinator.push(page: .Master_Charts)
                            }
                            CustomSettingsButton(title: "Change description") {
                                withAnimation(.linear) {
                                    isShowDesc.toggle()
                                }
                            }
                        }
                        
                        CustomSettingsButton(title: "Save change") {
                            Task {
                                await masterViewModel.saveMaster_Profile()
                                let titleEnter = String(
                                    format: NSLocalizedString("saveSettings", comment: ""))
                                let subTitle = String(
                                    format: NSLocalizedString("saveSettingsTitle", comment: ""))
                                NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
                            }
                        }
                        CustomSettingsButton(title: "Sign out") {
                            isPressAlarm = true
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .createBackgrounfFon()
            .ignoresSafeArea(.keyboard)
            .photosPicker(isPresented: $isChangeProfilePhoto, selection: $photoPickerItems, matching: .images)
            .imageViewSelected(isPressFullScreen: $isPressFullScreen, selectedImage: selectedImage ?? "", isShowTrash: true) {
                masterViewModel.deleteImage(image: selectedImage ?? "")
            }
            .customAlert(isPresented: $isPressAlarm, hideCancel: true, message: "Are you sure want to exit?",
                         title: "Leave Session", onConfirm: {signOut()}, onCancel: {})
            .scrollIndicators(.hidden)
            .onTapGesture {
                withAnimation {
                    
                    isEditor = true
                    UIApplication.shared.endEditing(true)
                    isEditor = false
                }
            }
        }
        .onChange(of: photoPickerItems) {
            guard let uid = authViewModel.auth.currentUser?.uid else { return }
            Task {
                if let photoPickerItems,
                   let data = try? await photoPickerItems.loadTransferable(type: Data.self) {
                    if UIImage(data: data) != nil {
                        
                        if let url = await Master_DataBase.shared.uploadImage_URLAvatar_Storage_Master(imageData: data) {
                            await Master_DataBase.shared.updateImageFireBase_Master(id: uid, url: url)
                            await masterViewModel.fetchProfile_Master()
                        }
                    }
                }
                photoPickerItems = nil
            }
            
        }
        .onDisappear {
            Master_DataBase.shared.deinitListener()
            
        }
    }
    private func signOut() {
        Task {
            selectedAdminID = nil
            useRole = ""
            authViewModel.signOut()
            try await google.logOut()
            coordinator.popToRoot()
        }
    }
}

#Preview {
    SettingsMasterController(masterViewModel: MasterViewModel.shared, isPressFullScreen: .constant(true))
}

