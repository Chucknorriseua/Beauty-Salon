//
//  SettingsMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI
import PhotosUI

struct SettingsMaster: View {
    
    @StateObject var authViewModel = Auth_Master_ViewModel()
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    @StateObject var masterViewModel: MasterViewModel
    @StateObject private var keyBoard = KeyboardResponder()
    
    @AppStorage ("selectedAdmin") private var selectedAdminID: String?
    @AppStorage ("useRole") private var useRole: String = ""
    
    @State private var isPressAlarm: Bool = false
    @State private var isShowprofilephoto: Bool = false
    @State private var isEditor: Bool = false
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @Binding  var isPressFullScreen: Bool
    @State var selectedImage: String? = nil
    
    var body: some View {
        NavigationView(content: {
            GeometryReader { geo in
                ScrollView {
                    VStack(alignment: .center, spacing: 10) {
                        VStack {
                            HStack {
                                
                                PhotosPicker(selection: $photoPickerItems, matching: .images) {
                                    VStack {}
                                        .createImageView(model: masterViewModel.masterModel.image ?? "", width: geo.size.width * 0.3,
                                                         height: geo.size.height * 0.3 / 2)
                                }.padding(.leading, 6)
                                
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(masterViewModel.masterModel.name)
                                            .font(.system(size: 24, weight: .semibold))
                                    }
                                    Text(masterViewModel.masterModel.email)
                                    
                                }.foregroundStyle(Color(hex: "F3E3CE"))
                                    .lineLimit(3)
                                    .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.15)
                            }
                            
                        }.frame(width: geo.size.width * 0.95, height: geo.size.height * 0.17, alignment: .leading)
                            .background(.ultraThickMaterial.opacity(0.6), in: .rect(topLeadingRadius: 35,
                                                                                    topTrailingRadius: 35))
                        
                        HStack {
                            SettingsPhotoView(masterViewModel: masterViewModel, selectedImage: $selectedImage, isPressFullScreen: $isPressFullScreen, isShowPhotoPicker: $isShowprofilephoto)
                        }.padding(.bottom, -76)
                        
                        VStack(spacing: 10) {
                            VStack(spacing: 4) {
                                
                                SettingsButton(text: $masterViewModel.masterModel.name, title: "Name", width: geo.size.width * 1)
                                SettingsButton(text: $masterViewModel.masterModel.phone, title: "Phone +(000)", width: geo.size.width * 1)
                                    .keyboardType(.numberPad)
                                    .textContentType(.telephoneNumber)
                                    .onChange(of: masterViewModel.masterModel.phone) { _, new in
                                        masterViewModel.masterModel.phone = formatPhoneNumber(new)
                                    }
                                Button {
                                    isShowprofilephoto = true
                                } label: {
                                    HStack {
                                        Text("Upload photos of my work")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(.leading, 4)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 4)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                    .padding(.all, 12)
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal, 6)
                                }
                                
                            }.padding(.top, 6)
                            
                            ZStack(alignment: .topLeading) {
                                if masterViewModel.masterModel.description.isEmpty {
                                    Text("Please limit your input to 160 characters.")
                                        .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                                        .padding(.top, 4)
                                        .padding(.leading, 4)
                                }
                                TextEditor(text: $masterViewModel.masterModel.description)
                                    .scrollContentBackground(.hidden)
                                
                            }.padding(.leading, 6)
                                .padding(.bottom, 6)
                        }.frame(width: geo.size.width * 0.95, height: geo.size.height * 0.40, alignment: .leading)
                            .background(.ultraThickMaterial.opacity(0.6), in: .rect(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
                            .foregroundStyle(Color(hex: "F3E3CE"))
                        
                        //              Button
                        VStack {
                            HStack {
                                Button(action: {
                                    Task {
                                        await masterViewModel.saveMaster_Profile()
                                        let titleEnter = String(
                                            format: NSLocalizedString("saveSettings", comment: ""))
                                        let subTitle = String(
                                            format: NSLocalizedString("saveSettingsTitle", comment: ""))
                                        NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
                                    }
                                }, label: {
                                    Text("Save change")
                                        .foregroundStyle(Color.green)
                                        .frame(width: 140)
                                })
                                
                                Text("|")
                                    .foregroundStyle(Color.white).opacity(0.4)
                                    .fontWeight(.bold)
                                
                                Button(action: { isPressAlarm = true }, label: {
                                    Text("Sign out")
                                        .foregroundStyle(Color.red)
                                        .frame(width: 140)
                                })
                                
                            }.padding(.all)
                                .opacity(0.7)
                                .fontWeight(.heavy)
                            
                        }.background(.ultraThickMaterial.opacity(0.6), in: .rect(topLeadingRadius: 10,
                                                                                 bottomLeadingRadius: 40,
                                                                                 bottomTrailingRadius: 40,
                                                                                 topTrailingRadius: 10))
                        .padding(.bottom, 80)
                    }
                    .padding(.bottom, keyBoard.currentHeight / 2)
                }.scrollIndicators(.hidden)
                    .createBackgrounfFon()
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.5)) {
                            
                            isEditor = true
                            UIApplication.shared.endEditing(true)
                            isEditor = false
                        }
                    }
                
                    .imageViewSelected(isPressFullScreen: $isPressFullScreen, selectedImage: selectedImage ?? "", isShowTrash: true) {
                        masterViewModel.deleteImage(image: selectedImage ?? "")
                    }
            }.ignoresSafeArea(.keyboard, edges: .all)
            
                .customAlert(isPresented: $isPressAlarm, hideCancel: true, message: "Are you sure want to exit?",
                             title: "Leave Session", onConfirm: {
                    signOut()
                }, onCancel: {
                    
                })
            
                .onChange(of: photoPickerItems) {
                    guard let uid = authViewModel.auth.currentUser?.uid else { return }
                    Task {
                        if let photoPickerItems,
                           let data = try? await photoPickerItems.loadTransferable(type: Data.self) {
                            if UIImage(data: data) != nil {
                                
                                if let url = await Master_DataBase.shared.uploadImage_URLAvatar_Storage_Master(imageData: data) {
                                    await Master_DataBase.shared.updateImageFireBase_Master(id: uid, url: url)
                                    await masterViewModel.fetchProfile_Master(id: masterViewModel.masterModel.id)
                                }
                            }
                        }
                        photoPickerItems = nil
                    }
                    
                }
                .onDisappear {
                    Master_DataBase.shared.deinitListener()
                    
                }
        })
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
extension SettingsMaster: isFormValid {
    var isFarmValid: Bool {
        return masterViewModel.masterModel.description.count < 160
    }
}
