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
    
    
    @StateObject var masterViewModel = MasterViewModel.shared
    @StateObject private var authViewModel = Auth_Master_ViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @EnvironmentObject var coordinator: CoordinatorView
    
    @State private var selectedImage: Data? = nil
    @State private var photoPickerArray: [PhotosPickerItem] = []
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @State private var isPressFullScreen: Bool = false
    @State private var selectedImages: String? = nil
    @State private var isLocationAlarm: Bool = false
    @State private var selectedCategory: Categories = .nail
    @State private var isShowInfo: Bool = false
    @State private var isChangeProfilePhoto: Bool = false
    @State private var isShowCategories: Bool = false
    
    @State private var massage: String = ""
    @State private var title: String = ""
    
    var body: some View {
        GeometryReader(content: { geo in
            VStack {
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
                                                .frame(width: geo.size.width * 0.3,
                                                       height: geo.size.height * 0.2)
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
                            }.scrollIndicators(.hidden)
                            VStack {
                                
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        isShowInfo.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Change profile")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(.leading, 4)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 4)
                                        
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 44)
                                    .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                    
                                }
                                
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        coordinator.push(page: .Master_CreatePriceList)
                                    }
                                } label: {
                                    HStack {
                                        Text("Price list")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(.leading, 4)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 4)
                                        
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 44)
                                    .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                    
                                }
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        isChangeProfilePhoto.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Change profile photo")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(.leading, 4)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 4)
                                        
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 44)
                                    .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                    
                                }
                                PhotosPicker(selection: $photoPickerArray, maxSelectionCount: 10, selectionBehavior: .ordered) {
                                    HStack {
                                        Text("Upload photos of my work")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(.leading, 4)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 4)
                                        
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 44)
                                    .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                }
                            }.padding(.bottom, 0)
                        } else {
                            VStack {
                                SettingsButton(text: $masterViewModel.masterModel.name, title: "Name", width: geo.size.width * 1)
                                SettingsButton(text: $masterViewModel.masterModel.phone, title: "Phone +(000)", width: geo.size.width * 1)
                                    .keyboardType(.numberPad)
                                    .textContentType(.telephoneNumber)
                                    .onChange(of: masterViewModel.masterModel.phone) { _, new in
                                        masterViewModel.masterModel.phone = formatPhoneNumber(new)
                                    }
                                Button {
                                    isLocationAlarm = true
                                    massage = "Do you really want to update your location?"
                                    title = "Change you'r loacation?"
                                } label: {
                                    HStack {
                                        Text("Change geolocation")
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 24))
                                        
                                    }.padding(.all, 6)
                                        .frame(maxWidth: .infinity, maxHeight: 44)
                                        .foregroundStyle(Color.white)
                                        .background(Color.blue.opacity(0.6), in: .rect(cornerRadius: 18))
                                    
                                }
                                
                                
                                ZStack(alignment: .topLeading) {
                                    if masterViewModel.masterModel.description.isEmpty {
                                        Text("Please limit your input to 160 characters.")
                                            .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                                            .padding(.top, 4)
                                            .padding(.leading, 4)
                                    }
                                    TextEditor(text: $masterViewModel.masterModel.description)
                                        .scrollContentBackground(.hidden)
                                    
                                }.frame(height: 120)
                                    .foregroundStyle(Color(hex: "F3E3CE"))
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        isShowCategories.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Select categories")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(.leading, 4)
                                        Text("\(selectedCategory.displayName)")
                                            .foregroundStyle(Color.yellow)
                                            .font(.system(size: 18, weight: .bold))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 4)
                                    }.padding(.horizontal, 6)
                                    .frame(maxWidth: .infinity, maxHeight: 44)
                                    .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                    
                                }
                                
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        isShowInfo.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Back")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(.leading, 4)
                                        Spacer()
                                        Image(systemName: "chevron.left")
                                            .padding(.trailing, 4)
                                    }.padding(.horizontal, 6)
                                    .frame(maxWidth: .infinity, maxHeight: 44)
                                    .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                    
                                }
                                
                            }
                        }
                    }
                    CustomButton(title: "Update profile") {
                        masterViewModel.masterModel.categories = selectedCategory.rawValue
                        Task {
                            await masterViewModel.save_Profile()
                            NotificationController.sharet.notify(title: "Save settings", subTitle: "Your settings have been saved👌", timeInterval: 1)
                        }
                    }
                    
                }.padding(.horizontal, 8)
            }.createBackgrounfFon()
                .onAppear {
                    if let savedCategory = Categories(rawValue: masterViewModel.masterModel.categories) {
                        selectedCategory = savedCategory
                    }
                }
                .overlay {
                    if isShowCategories {
                        Color.clear
                            .ignoresSafeArea()
                            .overlay(alignment: .center) {
                                ZStack {
                                    MasterSelectCategoriesView(selectedCategory: $selectedCategory, isShowCategories: $isShowCategories) {
                                        withAnimation {
                                            isShowCategories.toggle()
                                        }
                                    }
                                }
                        }
                    }
                }
                .photosPicker(isPresented: $isChangeProfilePhoto, selection: $photoPickerItems, matching: .images)
       
            
        })
        .customAlert(isPresented: $masterViewModel.isAlert, hideCancel: true, message: masterViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
        .imageViewSelected(isPressFullScreen: $isPressFullScreen, selectedImage: selectedImages ?? "", isShowTrash: true, deleteImage: {
            masterViewModel.deleteImage(image: selectedImages ?? "")
        })
        .swipeBack(coordinator: coordinator)
        .onTapGesture {
            withAnimation(.snappy) {
                UIApplication.shared.endEditing(true)
            }
        }
        .customAlert(isPresented: $isLocationAlarm, hideCancel: true, message: massage, title: title, onConfirm: {
            Task { await locationManager.updateLocationMaster(company: masterViewModel.masterModel) }
        }, onCancel: {})
        
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
                    await masterViewModel.fetchProfile_Master(id: masterViewModel.masterModel.id)
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
                            await masterViewModel.fetchProfile_Master(id: masterViewModel.masterModel.id)
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
        })
    }
}
