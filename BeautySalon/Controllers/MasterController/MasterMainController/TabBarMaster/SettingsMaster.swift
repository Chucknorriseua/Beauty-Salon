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
    @StateObject var masterViewModel: MasterViewModel
    @StateObject private var keyBoard = KeyboardResponder()
    
    @AppStorage ("selectedAdmin") private var selectedAdminID: String?
    
    @State private var isPressAlarm: Bool = false
    @State private var isEditor: Bool = false
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @Binding  var isPressFullScreen: Bool
    @State var selectedImage: String? = nil
    
    var body: some View {
        
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    VStack {
                        HStack {
                            
                            PhotosPicker(selection: $photoPickerItems, matching: .images) {
                                
                                if let image = masterViewModel.masterModel.image, let url = URL(string: image) {
                                    
                                    WebImage(url: url)
                                        .resizable()
                                        .indicator(.activity)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geo.size.width * 0.3, height: geo.size.height * 0.3 / 2)
                                        .clipShape(Circle())
                                } else {
                                    Image("ab3")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geo.size.width * 0.3, height: geo.size.height * 0.3 / 2)
                                        .clipShape(Circle())
                                }
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
                        SettingsPhotoView(masterViewModel: masterViewModel, selectedImage: $selectedImage, isPressFullScreen: $isPressFullScreen)
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
                      
                        }.padding(.top, 6)
                        
                        Text("Description about you:").opacity(0.4)
                            .font(.system(size: 16, weight: .semibold))
                        TextEditor(text:  $masterViewModel.masterModel.description)
                            .multilineTextAlignment(.leading)
                            .scrollContentBackground(.hidden)
                            .padding(.bottom, 6).onTapGesture {
                                isEditor = true
                                UIApplication.shared.endEditing(true)
                                isEditor = false
                            }
                    }.frame(width: geo.size.width * 0.95, height: geo.size.height * 0.40, alignment: .leading)
                        .background(.ultraThickMaterial.opacity(0.6), in: .rect(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
                        .foregroundStyle(Color(hex: "F3E3CE"))
                       
                    //              Button
                    VStack {
                        HStack {
                            Button(action: {
                                Task {
                                    await masterViewModel.saveMaster_Profile()
                                    NotificationController.sharet.notify(title: "Save settings", subTitle: "Your settings have been saved👌", timeInterval: 1)
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
            
                .overlay(alignment: .center) {
                    
                    if isPressFullScreen, let selectedImage {
                        
                        Color.black
                            .ignoresSafeArea(.all)
                            .opacity(0.9)
                            .transition(.opacity)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    let image = selectedImage
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        
                                        masterViewModel.deleteImage(image: image)
                                        isPressFullScreen.toggle()
                                    }
                                    
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundStyle(Color.red.opacity(0.8))
                                        .font(.system(size: 32, weight: .bold))
                                }.padding(.trailing, 10)
                            }
                        
                        WebImage(url: URL(string: selectedImage))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minWidth: geo.size.width * 0.9, maxHeight: geo.size.height * 0.8)
                            .clipped()
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    isPressFullScreen = false
                                }
                            }.transition(.blurReplace)
                        
                    }
                }
        }.ignoresSafeArea(.keyboard, edges: .all)
        
            .customAlert(isPresented: $isPressAlarm, message: "Are you sure you want to leave?",
                         title: "Leave session", onConfirm: {
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
    }
    private func signOut() {
        Task {
            
            selectedAdminID = nil
            authViewModel.signOut()
            try await GoogleSignInViewModel.shared.logOut()
            coordinator.popToRoot()
        }
    }
}
