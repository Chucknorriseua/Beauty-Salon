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
    @EnvironmentObject var apple: AppleAuthViewModel
    @EnvironmentObject var storekit: StoreViewModel
    @StateObject private var checkProfile = SignInValidator()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            Group {
                VStack(alignment: .center, spacing: 60) {
                    Spacer()
                    VStack(alignment: .center, spacing: 20) {
                        
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
                        
                    }
                    
                    VStack(alignment: .center, spacing: 12) {
                        Button {
                            Task {
                                await checkProfile.checkProfileAndGo(coordinator: coordinator)
                            }
                        } label: {
                            Text("Sign In")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .background(Color(red: 0.11, green: 0.14, blue: 0.12))
                                .clipShape(.rect(cornerRadius: 18, style: .continuous))
                        }
                        
                        VStack {
                            AppleButtonView(isNotUseCoordinator: false)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 56)
                        .clipShape(.rect(cornerRadius: 18, style: .continuous))
                        
                        VStack {
                            Button {
                               
                                Task {
                                    try await google.checkSubscribeGoogleProfile(coordinator: coordinator)
                                }
                            } label: {
                                HStack {
                                    Image("google")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                    Text("Sign In")
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundStyle(Color.white)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .background(Color(red: 0.11, green: 0.14, blue: 0.12))
                                .clipShape(.rect(cornerRadius: 18, style: .continuous))
                            }
                        }
                        
                        Button {
                            coordinator.push(page: .Main_Reg_Profile)
                        } label: {
                            Text("If you don't have an account, create one.")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .background(Color(red: 0.11, green: 0.14, blue: 0.12))
                                .clipShape(.rect(cornerRadius: 18, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 100)
                .onDisappear {
                    checkProfile.signIn.password = ""
                }
            }
            
        }.createBackgrounfFon()
            .overlay(alignment: .top) {
                VStack(alignment: .center) {
                    Text("Welcome in My Beauty Hub")
                        .foregroundStyle(Color.yellow)
                        .font(.system(size: 24, weight: .heavy))
                        .multilineTextAlignment(.center)
                }
                
            }
            .onAppear {
                locationManager.startUpdate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Task {
                        await checkProfile.loadProfile(coordinator: coordinator)
                    }
                }
//                if storekit.hasActiveSubscribe == true || storekit.useRole == "Client" {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        Task {
//                            await checkProfile.loadProfile(coordinator: coordinator)
//                        }
//                    }
//                }
            }
            .overlay(alignment: .center) { CustomLoader(isLoader: $checkProfile.isLoader, text: $checkProfile.loader) }
            .customAlert(isPresented: $checkProfile.isPressAlarm, hideCancel: false, message: checkProfile.message, title: "Something went wrong", onConfirm: {}, onCancel: {})
        
            .customAlert(isPresented: $checkProfile.isSubscribe, hideCancel: true, message: "You don't have a subscription, to enter you need to buy a subscription", title: "Buy a Subscription", onConfirm: {
                checkProfile.isBuySubscribe = true
            }, onCancel: {})
        
            .customAlert(isPresented: $apple.isSubscribe, hideCancel: true, message: "You don't have a subscription, to enter you need to buy a subscription", title: "Buy a Subscription", onConfirm: {
                checkProfile.isBuySubscribe = true
            }, onCancel: {})
        
            .customAlert(isPresented: $google.isSubscribe, hideCancel: true, message: "You don't have a subscription, to enter you need to buy a subscription", title: "Buy a Subscription", onConfirm: {
                checkProfile.isBuySubscribe = true
            }, onCancel: {})
            .customAlert(isPresented: $storekit.isBuySubscribe, hideCancel: true, message: "You don't have a subscription, to enter you need to buy a subscription", title: "Buy a Subscription", onConfirm: {
                checkProfile.isBuySubscribe = true
            }, onCancel: {})
            .sheet(isPresented: $checkProfile.isBuySubscribe) {
                SheetStoreKitProductSelect()
                    .presentationDetents([.large])
            }
            .ignoresSafeArea(.keyboard)
    }
}

