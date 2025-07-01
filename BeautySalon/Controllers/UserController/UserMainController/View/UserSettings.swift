//
//  UserSettings.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 03/10/2024.
//

import SwiftUI

struct UserSettings: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var taskTitle: String = ""
    @State private var taskService: String = ""
    @Binding var isDeleteMyProfile: Bool
    @State var isShowDeleteButton: Bool = false
    @State var isShowSaveButtonFavorites: Bool = false
    @Binding var isShowSubscription: Bool
    
    @AppStorage("useRole") private var useRole: String?
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    @StateObject private var auth = Auth_ClientViewModel()
    @ObservedObject var clientViewModel = ClientViewModel.shared
    
    var body: some View {
            
            VStack(spacing: 10,  content: {
         
                VStack {
                    
                    VStack(spacing: 10) {
                        
                        SettingsTextField(text: $clientViewModel.clientModel.name, title: "Change name", width: .infinity)
                        SettingsTextFieldPhone(text: $clientViewModel.clientModel.phone, title: "Phone +(000)", width: .infinity)
                        CustomSettingsButton(title: "Buy subscription") {
                            withAnimation(.easeOut(duration: 1)) {
                                dismiss()
                                isShowSubscription = true
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 6)
                        if isShowDeleteButton {
                            CustomSettingsButton(title: "Delete my Profile") {
                                dismiss()
                                isDeleteMyProfile = true
                            }
                            .padding(.horizontal, 6)
                            .padding(.top, 10)
                        }
                        CustomSettingsButton(title: "Exit my Profile") {
                            Task {
                                dismiss()
                                useRole = ""
                                try await google.logOut()
                                auth.signOutClient()
                                coordinator.popToRoot()
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 6)
                    }
                    .font(.system(size: 16, weight: .medium))
                    
                    HStack {
                        if isShowSaveButtonFavorites {
                            MainButtonSignIn(image: "person.crop.circle.fill", title: "Save", action: {
                                Task {
                                    await clientViewModel.save_UserProfilesMyFavorites()
                                    let titleEnter = String(
                                        format: NSLocalizedString("saveSettings", comment: ""))
                                    let subTitle = String(
                                        format: NSLocalizedString("saveSettingsTitle", comment: ""))
                                    NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
                                    dismiss()
                                }
                            })
                        } else {
                            MainButtonSignIn(image: "person.crop.circle.fill", title: "Save", action: {
                                Task {
                                    await clientViewModel.save_UserProfile()
                                    let titleEnter = String(
                                        format: NSLocalizedString("saveSettings", comment: ""))
                                    let subTitle = String(
                                        format: NSLocalizedString("saveSettingsTitle", comment: ""))
                                    NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
                                    dismiss()
                                }
                            })
                        }
                    }
                }
                .padding(.top, 16)
                Spacer()
            })
            .sheetColor()
            .ignoresSafeArea(.keyboard)
    }
}
