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
    @EnvironmentObject var googleSignInViewModel: GoogleSignInViewModel
    
    @ObservedObject private var authAdmin = Auth_ADMIN_Viewmodel()
    @ObservedObject private var authMaster = Auth_Master_ViewModel()
    @ObservedObject private var authClient = Auth_ClientViewModel()
    @StateObject private var signIn = SignInViewModel()
   
    
    @State private var message: String = ""
    @State private var messageSubscribe: String = ""
    @State private var loader: String = "Loading"
    
    @State private var isLoader: Bool = false
    @State private var profile: Bool = false
    @State private var isBuySubscribe: Bool = false
    @State private var isPressAlarm: Bool = false
    @State private var isSubscribe: Bool = false
    
    var body: some View {
        NavigationStack {
            
            VStack {
                VStack(alignment: .center, spacing: 10) {
                    
                    CustomTextField(text: $signIn.email,
                                    title: "Email",
                                    width: UIScreen.main.bounds.width - 20,
                                    showPassword: $signIn.showPassword)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                        
                    CustomTextField(text: $signIn.password,
                                    title: "Password",
                                    width: UIScreen.main.bounds.width - 20,
                                    showPassword: $signIn.showPassword)
                    
                    CustomButton(title: "Sign In") {
                        isLoader = true
                        Task { await checkProfileAndGo()}
                    }
                    
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel()) {
                        Task {
                            let check = try await checkSubscribeGoogleProfile()
                            guard check else {
                                isSubscribe = true
                                messageSubscribe = "You don't have a subscription, to enter you need to buy a subscription"
                                return
                            }
                        }
                    }.clipShape(.rect(cornerRadius: 24, style: .continuous))
                        .frame(width: 300)
                    
                }.onDisappear(perform: {
                    signIn.password = ""
                })
                
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
        .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
        .customAlert(isPresented: $isPressAlarm, message: message, title: "Something went wrong", onConfirm: {}, onCancel: {})
        .customAlert(isPresented: $isSubscribe, message: messageSubscribe, title: "Buy a Subscription", onConfirm: {
            isBuySubscribe = true
        }, onCancel: {})
        .sheet(isPresented: $isBuySubscribe) {
            SheetStoreKitProductSelect(storeKitView: StoreViewModel.shared)
            .presentationDetents([.height(320)])
    }
        .ignoresSafeArea(.keyboard)
    }
    
    private func checkProfileAndGo() async {
        Task {
            do {
                let email = signIn.email
                if try await authAdmin.signIn(email: email, password: signIn.password) {
                    let checkSubscribe = try await checkSubscribeAdminProfile()
                    guard checkSubscribe else {
                        isLoader = false
                        return
                    }
                        coordinator.push(page: .Admin_main)
                } else if try await  authMaster.signIn(email: email, password: signIn.password) {
                    let checkSubscribe = try await checkSubscribeMasterProfile()
                    guard checkSubscribe else {
                        isLoader = false
                        return
                    }
                    coordinator.push(page: .Master_Select_Company)
                } else if try await authClient.signIn(email: email, password: signIn.password) {
                    await ClientViewModel.shared.fetchAll_Comapny()
                    coordinator.push(page: .User_Main)
                    isLoader = false
                } else {
                    isLoader = false
                    isPressAlarm = true
                    message = "Not correct password or email, Make sure you are using the correct account. "
                }
            } catch {
                message = error.localizedDescription
            }
        }
    }
    
    private func checkSubscribeAdminProfile() async throws -> Bool {
        if StoreViewModel.shared.checkSubscribe {
                await AdminViewModel.shared.fetchProfileAdmin()
            isLoader = false
            return true
        } else {
            isLoader = false
            isBuySubscribe = true
            return false
        }
    }
    
    private func checkSubscribeMasterProfile() async throws -> Bool {
        if StoreViewModel.shared.checkSubscribe {
                await MasterViewModel.shared.getCompany()
            isLoader = false
            return true
        } else {
            isLoader = false
            isBuySubscribe = true
            return false
        }
    }
    
    private func checkSubscribeGoogleProfile() async throws -> Bool {
        if StoreViewModel.shared.checkSubscribe {
            if googleSignInViewModel.isLogin {
                googleSignInViewModel.goConntrollerProfile(coordinator: coordinator)
            } else {
                googleSignInViewModel.signInWuthGoogle(coordinator: coordinator)
            }
            return true
        } else {
            return false
        }
    }
}
