//
//  SignInValidator.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 05/12/2024.
//

import SwiftUI

@MainActor
class SignInValidator: ObservableObject {
    
    static var shared = SignInValidator()
    
    @AppStorage ("useRole") private var useRole: String = ""
    @AppStorage ("selectedAdmin") private var selectedAdminID: String?
    @AppStorage ("isLaunchFirst") private var isLaunchFirst: Bool?
    
    @Published var signIn = SignInViewModel()
    
    
    @Published var message: String = ""
    @Published var messageSubscribe: String = ""
    @Published var loader: String = "Loading"
    
    @Published var isLoader: Bool = false
    @Published var isBuySubscribe: Bool = false
    @Published var isPressAlarm: Bool = false
    @Published var isSubscribe: Bool = false
    @Published var hasActive: Bool = false
    
    init() {}
    
    func checkProfileAndGo(coordinator: CoordinatorView) async {
        do {
            isLoader = true
            defer {  
                self.isLoader = false
                hasActive = true
            }
            let email = signIn.email
            if try await Auth_ADMIN_Viewmodel.shared.signIn(email: email, password: signIn.password) {
                let checkSubscribe = try await checkSubscribeAdminProfile()
                guard checkSubscribe else {return}
                useRole = "Admin"
                coordinator.push(page: .Admin_main)
            } else if try await  Auth_Master_ViewModel.shared.signIn(email: email, password: signIn.password) {
                let checkSubscribe = try await checkSubscribeMasterProfile()
                guard checkSubscribe else {return}
                useRole = "Master"
                coordinator.push(page: .Master_Select_Company)
            } else if try await Auth_ClientViewModel.shared.signIn(email: email, password: signIn.password) {
                useRole = "Client"
                coordinator.push(page: .User_Main)
            } else {
                isLoader = false
                isPressAlarm = true
                message = "Not correct password or email, Make sure you are using the correct account."
            }
        } catch {
            message = error.localizedDescription
        }
        
    }

    private func checkSubscribeAdminProfile() async throws -> Bool {

        if StoreViewModel.shared.checkSubscribe && StoreViewModel.shared.purchasedSubscriptions.contains(where: { StoreViewModel.shared.adminProductIds.contains($0.id) }) {
            return true
        } else {
            isLoader = false
            isBuySubscribe = true
            return false
        }
    }

    private func checkSubscribeMasterProfile() async throws -> Bool {

        if StoreViewModel.shared.checkSubscribe && StoreViewModel.shared.purchasedSubscriptions.contains(where: { StoreViewModel.shared.masterProductIds.contains($0.id) }) {
            return true
        } else {
            isLoader = false
            isBuySubscribe = true
            return false
        }
    }
    
    func loadProfile(coordinator: CoordinatorView) async {
        self.isLoader = true
        defer {  self.isLoader = false }
        
        if isLaunchFirst == nil {
            isLaunchFirst = false
            return
        }
        
        if useRole == "Client" {
            _ = await self.checkRoleEntryInRoom(coordinator: coordinator)
        } else {
            if StoreViewModel.shared.checkSubscribe {
                _ = await self.checkRoleEntryInRoom(coordinator: coordinator)
            } else {
                self.messageSubscribe = "Your subscription has expired. To continue enjoying our services, please renew your subscription."
                self.isSubscribe = true
            }
        }
    }
    
    private func checkRoleEntryInRoom(coordinator: CoordinatorView) async -> Bool {
        if useRole == "Admin" {
            defer {
                hasActive = true
            }
            if  Auth_ADMIN_Viewmodel.shared.auth.currentUser != nil {
                coordinator.push(page: .Admin_main)
            }
        } else if useRole == "Master" {
            if  Auth_Master_ViewModel.shared.auth.currentUser != nil {
                if let saveAdmin = selectedAdminID {
         
                    MasterCalendarViewModel.shared.company.adminID = saveAdmin
                    coordinator.push(page: .Master_Main)
                }
            }
        } else if useRole == "Client" {
            if  Auth_ClientViewModel.shared.auth.currentUser != nil {
                coordinator.push(page: .User_Main)
            }
        }
        return false
    }
}
