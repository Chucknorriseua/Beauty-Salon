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
    @AppStorage ("fcnTokenUser") var fcnTokenUser: String = ""
    
    
    @MainActor
    func registerProfileWithGoogle(coordinator: CoordinatorView, id: String) async throws {
        switch rolePersone {
        case "Admin":
            let admin = Company_Model(id: id, adminID: id, name: fullName,
                                      companyName: nameCompany, adress: adress,
                                      email: email, phone: phone, description: textEditorDescrt, image: "", procedure: [], likes: 0, fcnTokenUser: fcnTokenUser, latitude: 0.0, longitude: 0.0, categories: "")
            
            try await Admin_DataBase.shared.setCompanyForAdmin(admin: admin)
            coordinator.popToRoot()
            
        case "Master":
            let master = MasterModel(id: id, masterID: id, name: fullName, email:
                                        email, phone: phone, description: textEditorDescrt, image: "", imagesUrl: [], categories: "", fcnTokenUser: fcnTokenUser, likes: 0, procedure: [], latitude: 0.0, longitude: 0.0)
            
            try await Master_DataBase.shared.setData_For_Master_FB(master: master)
            coordinator.popToRoot()
            
        case "Client":
            let client = Client(id: id, clientID: id, name: fullName, email: email, phone: phone, date: Date(), fcnTokenUser: fcnTokenUser, latitude: 0.0, longitude: 0.0, shedule: [])
            
            try await Client_DataBase.shared.setData_ClientFireBase(clientModel: client)
            coordinator.popToRoot()
        default:
            break
        }
    }
}
