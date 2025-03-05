//
//  SettingsAdminController.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 10/02/2025.
//

import SwiftUI
import PhotosUI

struct SettingsAdminController: View {
    
    
    @State private var isChangeProfile: Bool = false
    @State private var isChangeCategories: Bool = false

    @State private var isChangeProfilePhoto: Bool = false
    @State private var isShowInfo: Bool = false

    @State private var select: String? = nil
  
    @StateObject private var authViewModel = Auth_ADMIN_Viewmodel()
    @ObservedObject  var adminViewModel: AdminViewModel
    
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    
    @AppStorage ("useRole") private var useRole: String = ""
    
    @State private var isPressAlarm: Bool = false
    @State private var isLocationAlarm: Bool = false
    @State private var isEditor: Bool = false

    @State private var isShowTextField: Bool = false
    @State private var isShowAnother: Bool = false
    
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @State private var massage: String = ""
    @State private var title: String = ""
    @State private var description: String = "This category is intended for masters who take clients at home or with a visit to the client."
    @State private var descAnother: String = "The 'Another' category means that you provide additional services such as Thai massage or other health and beauty services."
    
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            VStack {}
                                .createImageView(model: adminViewModel.adminProfile.image ?? "", width: 100, height: 100)
                            
                            VStack(spacing: 0) {
                                Text(adminViewModel.adminProfile.companyName)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .lineLimit(4)
                                    .frame(maxWidth: 200, maxHeight: 80)
                            }
                            Spacer()
                        }
                  
                        HStack {
                            VStack(spacing: 18) {
                                if isChangeProfile {
                                    Text("Profile seetings")
                                        .foregroundStyle(Color.white)
                                        .fontWeight(.bold)
                                    SettingsTextField(text: $adminViewModel.adminProfile.name, title: "Name", width: .infinity)
                                    SettingsTextField(text: $adminViewModel.adminProfile.companyName, title: "Company name", width: .infinity)
                                    SettingsTextFieldPhone(text: $adminViewModel.adminProfile.phone, title: "phone", width: .infinity)
                                    SettingsTextField(text: $adminViewModel.adminProfile.adress, title: "adress", width: .infinity)
                                    Text("Salon description")
                                        .foregroundStyle(Color.white)
                                        .fontWeight(.bold)
                                    VStack {
                                        if adminViewModel.adminProfile.description.isEmpty {
                                            Text("Please limit your input to 160 characters.")
                                                .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                                                .padding(.leading, 4)
                                        }
                                        TextEditor(text: $adminViewModel.adminProfile.description)
                                            .scrollContentBackground(.hidden)
                                            .foregroundStyle(Color.white)
                                        
                                    }.frame(height: 150)
                                        .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                    CustomSettingsButton(title: "Back") {
                                        withAnimation(.linear) {
                                            isChangeProfile = false
                                        }
                                    }
                                    CustomSettingsButton(title: "Change photo") {
                                        isChangeProfilePhoto = true
                                    }
                                } else if !isChangeCategories {
                                    CustomSettingsButton(title: "Change profile") {
                                        withAnimation(.linear) {
                                            isChangeProfile = true
                                        }
                                    }
                                
                                    CustomSettingsButton(title: "Create service") {
                                        coordinator.push(page: .Admin_creatPrice)
                                    }
                                    
                                    CustomSettingsButton(title: "Home care") {
                                        coordinator.push(page: .Admin_HomeCare)
                                    }
                                    
                                    CustomSettingsButton(title: "Selected categories") {
                                        withAnimation(.linear) {
                                            isChangeCategories.toggle()
                                        }
                                    }
                             
                                    CustomSettingsButton(title: "Monthly salon statistics") {
                                        coordinator.push(page: .Admin_Charts)
                                    }
                                    CustomSettingsButton(title: "Change geolocation") {
                                        coordinator.push(page: .Admin_MapInfo)
                                    }
                                 
                                    CustomSettingsButton(title: "Sign out") {
                                        isPressAlarm = true
                                        massage = "Are you sure you want to exit?"
                                        title = "Log out of the profile"
                                    }
                                } else {
                                    SelectedCategories(selectedCtegory: $select, isShowInformation: $isShowInfo, isShowAnother: $isShowAnother)
                                        .onChange(of: select ?? "") { _, new in
                                            adminViewModel.adminProfile.categories = new
                                        }
                                    CustomSettingsButton(title: "Back") {
                                        withAnimation(.linear) {
                                            isChangeCategories = false
                                        }
                                    }
                                }
                                CustomSettingsButton(title: "Save change") {
                                    withAnimation(.linear) {
                                        isChangeProfile = false
                                        isChangeCategories = false
                                    }
                                    Task { await adminViewModel.setNew_Admin_Profile() }
                                    let titleEnter = String(
                                        format: NSLocalizedString("saveSettings", comment: ""))
                                    let subTitle = String(
                                        format: NSLocalizedString("saveSettingsTitle", comment: ""))
                                    NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
                                }
                            }
                     
                            Spacer()
                        }
             
                    }
                }
                .transition(.slide)
                .padding(.top, 14)
                .padding(.horizontal, 8)
                .padding(.bottom, 110)
                .onTapGesture {
                    withAnimation {
                        isEditor = true
                        UIApplication.shared.endEditing(true)
                        isEditor = false
                    }
                }
        
            }
            .scrollIndicators(.hidden)
            .createBackgrounfFon()
            .ignoresSafeArea(.keyboard)
            .photosPicker(isPresented: $isChangeProfilePhoto, selection: $photoPickerItems, matching: .images)
            .customAlert(isPresented: $isPressAlarm, hideCancel: true, message: massage,title: title, onConfirm: {
                Task {await signOutProfile()}
            }, onCancel: {})
            .informationView(isShowInfo: $isShowInfo, image: "makeup", text: description) {
                withAnimation(.linear) {
                    isShowInfo = false
                }
            }
            .informationView(isShowInfo: $isShowAnother, image: "another", text: descAnother) {
                withAnimation(.linear) {
                    isShowAnother = false
                }
            }
        }
        .onChange(of: photoPickerItems) {
                guard let uid = authViewModel.auth.currentUser?.uid else { return }
                Task {
                    if let photoPickerItems,
                       let data = try? await photoPickerItems.loadTransferable(type: Data.self) {
                        if UIImage(data: data) != nil {
                            
                            if let url = await Admin_DataBase.shared.upDatedImage_URL_Firebase_Admin(imageData: data) {
                                await Admin_DataBase.shared.uploadImageFireBase_Admin(id: uid, url: url)
                                await adminViewModel.refreshProfileAdmin()
                                
                            }
                        }
                    }
                    photoPickerItems = nil
                }
                
            }
        .onAppear {
            if let categories = Categories(rawValue: adminViewModel.adminProfile.categories) {
                select = categories.rawValue
            }
        }
    }
  
    private func signOutProfile() async {
        Task {
            useRole = ""
            await authViewModel.signOut()
            try await google.logOut()
            coordinator.popToRoot()
        }
    }
}

#Preview {
    SettingsAdminController(adminViewModel: AdminViewModel.shared)
}
