//
//  SignInValidator.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 05/12/2024.
//

import SwiftUI

@MainActor
final class SignInValidator: ObservableObject {
    
    static var shared = SignInValidator()
    
    @AppStorage("useRole") var useRole: String = ""
    @AppStorage("selectedAdmin") private var selectedAdminID: String?

    
    @Published var signIn = SignInViewModel()
    
    
    @Published var message: String = ""
    @Published var messageSubscribe: String = ""
    @Published var loader: String = "Loading"
    
    @Published var isLoader: Bool = false
    @Published var isBuySubscribe: Bool = false
    @Published var isPressAlarm: Bool = false
    @Published var isSubscribe: Bool = false
    @Published var isHasActives: Bool = false
    
    init() {}
    
    @MainActor
    func checkProfileAndGo(coordinator: CoordinatorView) async {
        do {
            isLoader = true
            defer {  
                self.isLoader = false
                isHasActives = true
            }
            let email = signIn.email
            
            if try await Auth_ADMIN_Viewmodel.shared.signIn(email: email, password: signIn.password) {
                useRole = "Admin"
//                let checkSubscribe = try await checkSubscribeAdminProfile()
//                guard checkSubscribe else {return}
                await AdminViewModel.shared.fetchProfileAdmin()
                coordinator.push(page: .Admin_main)
            } else if try await  Auth_Master_ViewModel.shared.signIn(email: email, password: signIn.password) {
                useRole = "Master"
//                let checkSubscribe = try await checkSubscribeMasterProfile()
//                guard checkSubscribe else {return}
                await MasterViewModel.shared.fetchProfile_Master()
                coordinator.push(page: .Master_Select_Company)
            } else if try await Auth_ClientViewModel.shared.signIn(email: email, password: signIn.password) {
                useRole = "Client"
                await ClientViewModel.shared.fetchAll_Comapny()
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

//    private func checkSubscribeAdminProfile() async throws -> Bool {
//
//        if StoreViewModel.shared.checkSubscribe && StoreViewModel.shared.purchasedSubscriptions.contains(where: { StoreViewModel.shared.adminProductIds.contains($0.id) }) {
//            return true
//        } else {
//            isLoader = false
//            isBuySubscribe = true
//            return false
//        }
//    }
//
//    private func checkSubscribeMasterProfile() async throws -> Bool {
//
//        if StoreViewModel.shared.checkSubscribe && StoreViewModel.shared.purchasedSubscriptions.contains(where: { StoreViewModel.shared.masterProductIds.contains($0.id) }) {
//            return true
//        } else {
//            isLoader = false
//            isBuySubscribe = true
//            return false
//        }
//    }
    
    @MainActor
    func loadProfile(coordinator: CoordinatorView) async {
        self.isLoader = true
        defer {  self.isLoader = false }

        if useRole == "Client" {
            _ = await self.checkRoleEntryInRoom(coordinator: coordinator)
        } else {
            _ = await self.checkRoleEntryInRoom(coordinator: coordinator)
        }
    }
    
    @MainActor
    private func checkRoleEntryInRoom(coordinator: CoordinatorView) async -> Bool {
        defer {
            isHasActives = true
        }
        if useRole == "Admin" {
            if  Auth_ADMIN_Viewmodel.shared.auth.currentUser != nil {
                coordinator.push(page: .Admin_main)
            }
        } else if useRole == "Master" {
            if  Auth_Master_ViewModel.shared.auth.currentUser != nil {
                if let saveAdmin = selectedAdminID {
                    MasterViewModel.shared.admin.adminID = saveAdmin
                    MasterCalendarViewModel.shared.company.adminID = saveAdmin
                    coordinator.push(page: .Master_Main)
                } else {
                    coordinator.push(page: .Master_Select_Company)
                }
            }
        } else if useRole == "Client" {
            if  Auth_ClientViewModel.shared.auth.currentUser != nil {
                coordinator.push(page: .User_Main)
            }
        } else if useRole == "" {
            print("non enter person")
        }
        return false
    }
}
