//
//  SettingsView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI
import PhotosUI

struct SettingsAdminView: View {
    
    @StateObject private var authViewModel = Auth_ADMIN_Viewmodel()
    @StateObject private var locationManager = LocationManager()
    @StateObject  var adminViewModel: AdminViewModel
    @StateObject private var keyBoard = KeyboardResponder()
    
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    
    @AppStorage ("useRole") private var useRole: String?
    @State private var selectedCategory: Categories = .nail
    
    @State private var isPressAlarm: Bool = false
    @State private var isLocationAlarm: Bool = false
    @State private var isEditor: Bool = false
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @State private var massage: String = ""
    @State private var title: String = ""
    
    
    var body: some View {
        
        GeometryReader(content: { geometry in
            ScrollView {
                
                VStack(alignment: .center, spacing: 20) {
                    
                    VStack {
                        VStack {
                            
                            HStack(alignment: .center, spacing: 10) {
                                PhotosPicker(selection: $photoPickerItems, matching: .images) {
                                    VStack {}
                                        .createImageView(model: adminViewModel.adminProfile.image ?? "", width: geometry.size.width * 0.3, height: geometry.size.height * 0.3 / 2)
                                }
                                
                                VStack(spacing: 10) {
                                    
                                    Text(adminViewModel.adminProfile.companyName)
                                        .font(.system(size: 24, weight: .semibold))
                                        .lineLimit(2)
                                    
                                    Text(adminViewModel.adminProfile.email)
                                    
                                }.foregroundStyle(Color(hex: "F3E3CE"))
                                    .frame(width: 200, height: 100)
                                
                            }.frame(width: geometry.size.width * 0.9,
                                    height: geometry.size.height * 0.25, alignment: .leading)
                            
                            
                        } .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.2)
                            .background(.ultraThickMaterial.opacity(0.6), in: .rect(topLeadingRadius: 35,
                                                                                    topTrailingRadius: 35))
                        VStack(spacing: 14) {
                            VStack(spacing: 4) {
                                
                                SettingsButton(text: $adminViewModel.adminProfile.companyName,
                                               title: "Compane name", width: geometry.size.width * 1)
                                
                                SettingsButton(text: $adminViewModel.adminProfile.name,
                                               title: "Name", width: geometry.size.width * 1)
                                
                                SettingsButton(text: $adminViewModel.adminProfile.phone,
                                               title: "Phone +(000)-000-000-00-00", width: geometry.size.width * 1)
                                .keyboardType(.numberPad)
                                .textContentType(.telephoneNumber)
                                .onChange(of: adminViewModel.adminProfile.phone) { _, new in
                                    adminViewModel.adminProfile.phone = formatPhoneNumber(new)
                                }
                                
                                SettingsButton(text: $adminViewModel.adminProfile.adress,
                                               
                                               title: "Adress", width: geometry.size.width * 1)
                                HStack {
                                    Text("Selected categories: ")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                    
                                    Picker("", selection: $selectedCategory) {
                                        Image(systemName: "filemenu.and.selection")
                                        ForEach(Categories.allCases, id: \.id) { category in
                                            Text(category.displayName).tag(category)
                                        }
                                        
                                    }.pickerStyle(.menu)
                                        .onChange(of: selectedCategory, { _, new in
                                            adminViewModel.adminProfile.categories = new.rawValue
                                        })
                                        .tint(Color(hex: "F3E3CE")).opacity(0.7)
                                    Spacer()
                                    
                                }.frame(maxWidth: .infinity, maxHeight: 44)
                                .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal, 4)
                                
                                Button {
                                    isLocationAlarm = true
                                    massage = "Do you really want to update your location?"
                                    title = "Change you'r loacation?"
                                } label: {
                                    HStack {
                                        Text("Change geolocation")
                                        Image(systemName: "location.fill")
                                            .foregroundStyle(Color.white.opacity(0.9))
                                            .font(.system(size: 24))
                                        
                                    }.padding(.all, 4)
                                        .background(Color.blue.opacity(0.6), in: .rect(cornerRadius: 24))
                                }

                                ZStack(alignment: .topLeading) {
                                    if adminViewModel.adminProfile.description.isEmpty {
                                        Text("Please limit your input to 160 characters.")
                                            .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                                            .padding(.top, 4)
                                            .padding(.leading, 4)
                                    }
                                        TextEditor(text: $adminViewModel.adminProfile.description)
                                            .scrollContentBackground(.hidden)

                                }.padding(.leading, 6)
                                
                            }.padding(.top, 6)
                            
                        }.frame(width: geometry.size.width * 0.95,
                                height: geometry.size.height * 0.6)
                        
                        .background(.ultraThickMaterial.opacity(0.6), in: .rect(bottomLeadingRadius: 24,
                                                                                bottomTrailingRadius: 24))
                        .foregroundStyle(Color(hex: "F3E3CE"))
                        
                    }
                    //              Button
                    VStack {
                        HStack {
                            Button(action: { Task {
                                await adminViewModel.setNew_Admin_Profile()
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
                            
                            Button(action: {
                                isPressAlarm = true
                                massage = "Are you sure you want to exit?"
                                title = "Leave session"
                            }, label: {
                                Text("Sign out")
                                    .foregroundStyle(Color.red)
                                    .frame(width: 140)
                            })
                            
                        }.padding(.all).opacity(0.8)
                        
                    }.background(.ultraThickMaterial.opacity(0.6), in: .rect(topLeadingRadius: 10,
                                                                             bottomLeadingRadius: 40,
                                                                             bottomTrailingRadius: 40,
                                                                             topTrailingRadius: 10))
                    .padding(.bottom, 80)
                    
                }.padding(.bottom, keyBoard.currentHeight / 2)
            }.scrollIndicators(.hidden)
                .createBackgrounfFon()
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.5)) {
                        
                        isEditor = true
                        UIApplication.shared.endEditing(true)
                        isEditor = false
                    }
                }
            
        }).ignoresSafeArea(.keyboard, edges: .bottom)
            .customAlert(isPresented: $isLocationAlarm, hideCancel: true, message: massage, title: title, onConfirm: {
                Task { await locationManager.updateLocation(company: adminViewModel.adminProfile) }
            }, onCancel: {})
            .customAlert(isPresented: $isPressAlarm, hideCancel: true, message: massage,title: title, onConfirm: {
                Task {await signOutProfile()}
            }, onCancel: {})
        
            .onChange(of: photoPickerItems) {
                guard let uid = authViewModel.auth.currentUser?.uid else { return }
                Task {
                    if let photoPickerItems,
                       let data = try? await photoPickerItems.loadTransferable(type: Data.self) {
                        if UIImage(data: data) != nil {
                            
                            if let url = await Admin_DataBase.shared.upDatedImage_URL_Firebase_Admin(imageData: data) {
                                await Admin_DataBase.shared.uploadImageFireBase_Admin(id: uid, url: url)
                                
                            }
                        }
                    }
                    photoPickerItems = nil
                }
                
            }
        
            .onDisappear {
                Admin_DataBase.shared.deinitListener()
            }
            .onAppear {
                if let categories = Categories(rawValue: adminViewModel.adminProfile.categories) {
                    selectedCategory = categories
                }
            }
    }
    
    private func signOutProfile() async {
        Task {
            useRole = nil
            await authViewModel.signOut()
            try await google.logOut()
            coordinator.popToRoot()
        }
    }
}
extension SettingsAdminView: isFormValid {
    var isFarmValid: Bool {
        return adminViewModel.adminProfile.description.count < 160
    }
}

#Preview {
    SettingsAdminView(adminViewModel: AdminViewModel.shared)
}
