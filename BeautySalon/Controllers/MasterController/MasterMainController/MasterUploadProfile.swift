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
    
    
    @StateObject var masterViewModel: MasterViewModel
    @StateObject private var authViewModel = Auth_Master_ViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @EnvironmentObject var coordinator: CoordinatorView
    
    @State private var selectedImage: Data? = nil
    @State private var photoPickerArray: [PhotosPickerItem] = []
    @State private var isPressFullScreen: Bool = false
    @State private var selectedImages: String? = nil
    @State private var isLocationAlarm: Bool = false
    @State private var massage: String = ""
    @State private var title: String = ""
        
    var body: some View {
        GeometryReader(content: { geo in
            VStack {
                Group {
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
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                
                                                selectedImages = image
                                                isPressFullScreen = true
                                            }
                                        }.transition(.blurReplace)
                                }.id(image)
                                    .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .offset(y: phase.isIdentity ? 0 : -50)
                                    }
                            }
                        }.scrollTargetLayout()
                            .padding(.top, 50)
                    }.scrollIndicators(.hidden)
                    
                    SettingsButton(text: $masterViewModel.masterModel.name, title: "Name", width: geo.size.width * 1)
                    SettingsButton(text: $masterViewModel.masterModel.phone, title: "phone", width: geo.size.width * 1)
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
                                .foregroundStyle(Color(hex: "F3E3CE"))
                            Image(systemName: "location.fill")
                                .foregroundStyle(Color.white.opacity(0.9))
                                .font(.system(size: 24))
                          
                        }.padding(.all, 4)
                        .background(Color.blue.opacity(0.6), in: .rect(cornerRadius: 24))
                    }
                    
                    
                    Text("Description about you:").opacity(0.8)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 16, weight: .semibold))
                    
                    VStack {
                        
                        TextEditor(text:  $masterViewModel.masterModel.description)
                            .frame(height: geo.size.height * 0.3)
                            .background(.ultraThickMaterial.opacity(0.6), in: .rect(bottomLeadingRadius: 16, bottomTrailingRadius: 16))
                            .foregroundStyle(Color(hex: "F3E3CE"))
                            .scrollContentBackground(.hidden)
            
                    }.padding(.leading, 4)
                        .padding(.trailing, 4)
                        .padding(.bottom, 6)
                    
                    CustomButton(title: "Update") {
                        Task {
                            await masterViewModel.save_Profile()
                            NotificationController.sharet.notify(title: "Save settings", subTitle: "Your settings have been saved👌", timeInterval: 1)
                        }
                    }
                    
                }
            }.padding(.leading, 4)
                .padding(.trailing, 4)
      
                .overlay(alignment: .topTrailing) {
                    PhotosPicker(selection: $photoPickerArray, maxSelectionCount: 10, selectionBehavior: .ordered) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 18))
                            
                        }.frame(width: geo.size.width * 0.14, height: geo.size.height * 0.07)
                            .background(Color.init(hex: "#3e5b47").opacity(0.6))
                            .clipShape(Circle())
                            .padding(.trailing, 6)
                    }
                }
            
            
                .overlay(alignment: .center) {
                    
                    if isPressFullScreen, let selectedImages {
                        ZStack {
                            Color.black
                                .ignoresSafeArea(.all)
                                .opacity(0.9)
                                .transition(.opacity)
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        let image = selectedImages
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
                            
                            WebImage(url: URL(string: selectedImages))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(minWidth: geo.size.width * 0.9, maxHeight: geo.size.height * 0.8)
                                .clipped()
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        isPressFullScreen = false
                                    }
                                }.transition(.blurReplace)
                        }
                        
                    }
                }
            
        }).createBackgrounfFon()
            .swipeBack(coordinator: coordinator)
            .onTapGesture {
                withAnimation(.snappy) {
                    UIApplication.shared.endEditing(true)
                }
            }
            .customAlert(isPresented: $isLocationAlarm, message: massage, title: title, onConfirm: {
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
            .onDisappear {
                Admin_DataBase.shared.deinitListener()
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading) {
                        if !isPressFullScreen {
                            TabBarButtonBack {
                                coordinator.pop()
                            }
                            Text("Profile")
                                .foregroundColor(.yellow)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                        } else { Text("") }
                    }.padding(.top, 20)
                }
            })
    }
}
