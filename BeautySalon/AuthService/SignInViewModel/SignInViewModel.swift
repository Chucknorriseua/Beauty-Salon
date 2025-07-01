//
//  SignInViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

final class SignInViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var nameCompany: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var showPassword: Bool = false
    @Published var fullName: String = ""
    @Published var phone: String = ""
    @Published var adress: String = ""
    @Published var isAnimation: Bool = false
    @Published var textEditorDescrt: String = ""
    @Published var rolePersone: String = ""
    @Published var selectCategories: String = ""
    @AppStorage("fcnTokenUser") var fcnTokenUser: String = ""
    
    
    @MainActor
    func registerProfileWithGoogle(coordinator: CoordinatorView, id: String) async throws {
        switch rolePersone {
        case "Admin":
            let admin = Company_Model(id: id, adminID: id, roleAdmin: "Admin", name: fullName,
                                      companyName: nameCompany, adress: adress,
                                      email: email, phone: phone, description: textEditorDescrt, image: "", procedure: [], likes: 0, fcnTokenUser: fcnTokenUser, latitude: 0.0, longitude: 0.0, categories: selectCategories)
            
            try await Admin_DataBase.shared.setCompanyForAdmin(admin: admin)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                coordinator.push(page: .Admin_main)
            }
        case "Master":
            let master = MasterModel(id: id, masterID: id, roleMaster: "Master", name: fullName, email:
                                        email, phone: phone, adress: "", description: textEditorDescrt, image: "", imagesUrl: [], categories: selectCategories, masterMake: "", fcnTokenUser: fcnTokenUser, likes: 0, procedure: [], latitude: 0.0, longitude: 0.0)
            
            try await Master_DataBase.shared.setData_For_Master_FB(master: master)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                coordinator.push(page: .Master_Select_Company)
            }
            
        case "Client":
            let client = Client(id: id, clientID: id, name: fullName, email: email, phone: phone, date: Date(), fcnTokenUser: fcnTokenUser, latitude: 0.0, longitude: 0.0, shedule: [])
            
            try await Client_DataBase.shared.setData_ClientFireBase(clientModel: client)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                coordinator.push(page: .User_Main)
            }
        default:
            break
        }
    }
}
