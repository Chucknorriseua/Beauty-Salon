//
//  MasterUploadProfile.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 02/11/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import PhotosUI

struct MasterUploadProfile: View {
    
    
    @ObservedObject var masterViewModel = MasterViewModel.shared
    @StateObject private var authViewModel = Auth_Master_ViewModel()
    
    @EnvironmentObject var coordinator: CoordinatorView
    
    @State private var selectedImage: Data? = nil
    @State private var photoPickerArray: [PhotosPickerItem] = []
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @State private var isPressFullScreen: Bool = false
    @State private var selectedImages: String? = nil
    @State private var select: String? = nil
    @State private var isShowSubscription: Bool = false
    
    @AppStorage("selectedAdmin") private var selectedAdminID: String?
    @AppStorage("useRole") private var useRole: String = ""

    @State private var isShowInfo: Bool = false
    @State private var isShowInformation: Bool = false
    @State private var isShowAnother: Bool = false
    @State private var isChangeProfilePhoto: Bool = false
    @State private var isChangeArrayPhoto: Bool = false
    @State private var isShowCategories: Bool = false
    @State private var isDeleteMyProfile: Bool = false
    @State private var massage: String = ""
    @State private var textFieldCateg: String = ""
    @State private var title: String = ""
    
    @State private var description: String = "This category is intended for masters who take clients at home or with a visit to the client."
    @State private var descAnother: String = "The 'Another' category means that you provide additional services such as Thai massage or other health and beauty services."
    
    var body: some View {
        GeometryReader(content: { geo in
            ScrollView {
                Group {
                    VStack {}
                        .createImageView(model: masterViewModel.masterModel.image ?? "", width: geo.size.width * 0.6, height: geo.size.height * 0.6 / 2)
                    VStack {
                        if !isShowInfo {
                            
                            ScrollView(.horizontal) {
                                LazyHStack {
                                    ForEach(masterViewModel.masterModel.imagesUrl ?? [], id:\.self) { image in
                                        HStack {
                                            WebImage(url: URL(string: image))
                                                .resizable()
                                                .indicator(.activity)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geo.size.width * 0.23,
                                                       height: geo.size.height * 0.23)
                                                .clipShape(Circle())
                                                .overlay(content: {
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2)
                                                })
                                                .onTapGesture {
                                                    withAnimation(.snappy(duration: 0.5)) {
                                                        
                                                        selectedImages = image
                                                        isPressFullScreen = true
                                                    }
                                                }.transition(.blurReplace)
                                        }.id(image)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .padding(.horizontal, 4)
                            .scrollIndicators(.hidden)
                            
                            VStack {
                                CustomSettingsButton(title: "Change profile") {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        isShowInfo.toggle()
                                    }
                                }
                                CustomSettingsButton(title: "Price list") {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        coordinator.push(page: .Master_CreatePriceList)
                                    }
                                }
                                CustomSettingsButton(title: "Monthly statistics") {
                                    coordinator.push(page: .Master_StaticMonthly)
              
                                }
                                CustomSettingsButton(title: "Working at the Salon") {
                                                                        coordinator.push(page: .Master_MasterWorkInSalon)
                                }
                                CustomSettingsButton(title: "Change profile photo") {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        isChangeProfilePhoto.toggle()
                                    }
                                }
                                CustomSettingsButton(title: "Upload photos of my work") {
                                    isChangeArrayPhoto.toggle()
                                }
                                
                                CustomSettingsButton(title: "Buy subscription") {
                                    withAnimation(.easeOut(duration: 1)) {
                                        isShowSubscription = true
                                    }
                                }
                                
                                CustomSettingsButton(title: "Exit my Profile") {
                                    withAnimation(.easeOut(duration: 1)) {
                                        signOut()
                                    }
                                }
                             
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 30)
                        } else {
                            VStack {
                                if isShowCategories {
                                    SelectedCategoriesMaster(selectedCtegory: $select,
                                                       isShowInformation: $isShowInformation,
                                                       isShowAnother: $isShowAnother,
                                                       isHideAnother: true)
                                    
                                        .onChange(of: select ?? "") { _, new in
                                            masterViewModel.masterModel.categories = new
                                        }
                                } else {
                                    SettingsTextField(text: $masterViewModel.masterModel.name, title: "Name", width: geo.size.width * 1)
                                    SettingsTextFieldPhone(text: $masterViewModel.masterModel.phone, title: "Phone +(000)", width: .infinity)
                                    
                                    ZStack(alignment: .topLeading) {
                                        if masterViewModel.masterModel.description.isEmpty {
                                            Text("Please limit your input to 160 characters.")
                                                .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                                                .padding(.top, 4)
                                                .padding(.leading, 4)
                                        }
                                        TextEditor(text: $masterViewModel.masterModel.description)
                                            .scrollContentBackground(.hidden)
                                        
                                    }
                                    .frame(height: 130)
                                    .foregroundStyle(Color.white)
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal, 4)
                                }
                               
                                CustomSettingsButton(title: "Select categories") {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        isShowCategories.toggle()
                                    }
                                }
                                CustomSettingsButton(title: "Change geolocation") {
                                    coordinator.push(page: .Maste_MapInfo)
              
                                }
                                CustomSettingsButton(title: "Delete my Profile") {
                                    isDeleteMyProfile = true
                                    massage = "Once your profile has been deleted, it can no longer be restored"
                                    title = "Do you really want to delete your profile?"
                                }
                                CustomSettingsButton(title: "Back") {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        isShowInfo.toggle()
                                        isShowCategories = false
                                    }
                                }
                            }
                        }
                    }
              
                }
                .padding(.bottom, 30)
                
            }
            .createBackgrounfFon()
            .overlay(alignment: .center, content: {
                if isShowSubscription {
                    StoreKitBuyAdvertisement(isXmarkButton: $isShowSubscription)
                }
            })
                .overlay(alignment: .bottom, content: {
                    if !isShowCategories {
                        
                        VStack {
                            CustomButton(title: "Update profile") {
                                Task {
                                    await masterViewModel.save_Profile()
                                    NotificationController.sharet.notify(title: "Save settings", subTitle: "Your settings have been saved👌", timeInterval: 1)
                                }
                            }
                        }
                    }
                })
                .ignoresSafeArea(.keyboard)
                .onAppear {
                   
                    if let categories = Categories(rawValue: masterViewModel.masterModel.categories) {
                        select = categories.rawValue
                    }
                    Task {
                        await masterViewModel.fetchSheduleFromClient()
                    }
                }
                .photosPicker(isPresented: $isChangeProfilePhoto, selection: $photoPickerItems, matching: .images)
                .photosPicker(isPresented: $isChangeArrayPhoto, selection: $photoPickerArray, maxSelectionCount: 10, selectionBehavior: .ordered)

            
        })
        .customAlert(isPresented: $masterViewModel.isAlert, hideCancel: true, message: masterViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
        .imageViewSelected(isPressFullScreen: $isPressFullScreen, selectedImage: selectedImages ?? "", isShowTrash: true, deleteImage: {
            masterViewModel.deleteImage(image: selectedImages ?? "")
        })
        .customAlert(isPresented: $isDeleteMyProfile, hideCancel: true, message: massage,title: title, onConfirm: {
            Task {
                try await Master_DataBase.shared.deleteMyProfileFromFirebase(profile: masterViewModel.masterModel)
                coordinator.popToRoot()
            }
        }, onCancel: {})
        .informationView(isShowInfo: $isShowInformation, textField: $masterViewModel.masterModel.masterMake, image: "makeup", text: description, isShowTextField: true, action: {
            Task {
                await masterViewModel.save_Profile()
                isShowInformation = false
            }
        }, dismiss: {
            withAnimation(.linear) {
                isShowInformation = false
            }
        })
        .informationView(isShowInfo: $isShowAnother, textField: $masterViewModel.masterModel.masterMake, image: "another", text: descAnother, isShowTextField: true, action: {
            Task {
                await masterViewModel.save_Profile()
                isShowAnother = false
            }
        }, dismiss: {
            withAnimation(.linear) {
                isShowAnother = false
            }
        })

        .swipeBack(coordinator: coordinator)
        .onTapGesture {
            withAnimation(.snappy) {
                UIApplication.shared.endEditing(true)
            }
        }
        
        .onChange(of: photoPickerArray) {
            guard let uid = authViewModel.auth.currentUser?.uid else { return }
            Task {
                
                var imageData: [Data] = []
                
                for item in photoPickerArray {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        imageData.append(data)
                    }
                }
                if !imageData.isEmpty {
                    await Master_DataBase.shared.uploadMultipleImages(id: uid, imageData: imageData)
                    await masterViewModel.fetchProfile_Master()
                }
                photoPickerArray.removeAll()
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
            Admin_DataBase.shared.deinitListener()
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                if !isPressFullScreen {
                    TabBarButtonBack {
                        coordinator.pop()
                    }
                } else {
                    Text("")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if !isPressFullScreen {
                    Button {
                        coordinator.push(page: .Master_Shedule)
                    } label: {
                       Image(systemName: "message.badge.filled.fill")
                            .resizable()
                            .foregroundStyle(Color.white)
                            .frame(width: 40, height: 40)
                            .overlay(alignment: .topTrailing) {
                                if !masterViewModel.sheduleFromClient.isEmpty {
                                    VStack {
                                        Text("\(masterViewModel.sheduleFromClient.count)")
                                            .foregroundStyle(Color.white)
                                            .padding(.all, 6)
                                    }
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .offset(y: -10)
                            }
                        }
                    }

                } else {
                    Text("")
                }
            }
        })
    }
    private func signOut() {
            Task {
                selectedAdminID = nil
                useRole = ""
                Auth_Master_ViewModel.shared.signOut()
                try await GoogleSignInViewModel.shared.logOut()
                coordinator.popToRoot()
        }
    }
}

 
