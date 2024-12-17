//
//  MainCoordinator.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 20/08/2024.
//

import SwiftUI
import GoogleSignInSwift

struct MainCoordinator: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    @StateObject private var checkProfile = SignInValidator()
    
    var body: some View {
        NavigationStack {
            
            VStack {
                VStack(alignment: .center, spacing: 10) {
                    
                    CustomTextField(text: $checkProfile.signIn.email,
                                    title: "Email",
                                    width: UIScreen.main.bounds.width - 20,
                                    showPassword: $checkProfile.signIn.showPassword)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                        
                    CustomTextField(text: $checkProfile.signIn.password,
                                    title: "Password",
                                    width: UIScreen.main.bounds.width - 20,
                                    showPassword: $checkProfile.signIn.showPassword)
                    
                    CustomButton(title: "Sign In") {
                        Task {
                            await checkProfile.checkProfileAndGo(coordinator: coordinator)
                        }
                    }
                    
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel()) {
                        Task {
                            let check = try await google.checkSubscribeGoogleProfile(coordinator: coordinator)
                            guard check else {
                                checkProfile.isSubscribe = true
                                checkProfile.messageSubscribe = "You don't have a subscription, to enter you need to buy a subscription"
                                return
                            }
                        }
                    }.clipShape(.rect(cornerRadius: 24, style: .continuous))
                        .frame(width: 300)
                    
                }.onDisappear {
                    checkProfile.signIn.password = ""
                }
                
                .padding()
                Button {
                    coordinator.push(page: .Main_Reg_Profile)
                } label: {
                    Text("If you don't have an account, create one.")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                }
            }.navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Welcom in Beauty Salon")
                        .foregroundStyle(Color.yellow.opacity(0.8))
                        .font(.system(size: 27, weight: .heavy).bold())
                }
            }

        }.createBackgrounfFon()
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Task {
                        await checkProfile.loadProfile(coordinator: coordinator)
                    }
                }
            }
            .overlay(alignment: .center) { CustomLoader(isLoader: $checkProfile.isLoader, text: $checkProfile.loader) }
            .customAlert(isPresented: $checkProfile.isPressAlarm, hideCancel: false, message: checkProfile.message, title: "Something went wrong", onConfirm: {}, onCancel: {})
            .customAlert(isPresented: $checkProfile.isSubscribe, hideCancel: false, message: checkProfile.messageSubscribe, title: "Buy a Subscription", onConfirm: {
                checkProfile.isBuySubscribe = true
        }, onCancel: {})
            .sheet(isPresented: $checkProfile.isBuySubscribe) {
            SheetStoreKitProductSelect(storeKitView: StoreViewModel.shared)
            .presentationDetents([.height(320)])
    }
        .ignoresSafeArea(.keyboard)
    }
}
