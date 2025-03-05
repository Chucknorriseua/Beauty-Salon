//
//  AuthFbHowAdminViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 25/08/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

protocol isFormValid {
    var isFarmValid: Bool { get }
}

@MainActor
final class Auth_ADMIN_Viewmodel: ObservableObject {
    
    static var shared = Auth_ADMIN_Viewmodel()
    
    @Published var locationManager = LocationManager()
    @Published var signInViewModel = SignInViewModel()
    @Published var selectedImage: Data? = nil
    @Published var currentUser: User? = nil
    @Published var message: String = ""
    @Published var showAlert: Bool = false
    @AppStorage ("fcnTokenUser") var fcnTokenUser: String = ""
    
    let auth = Auth.auth()
    
    init() {
        _ = auth.addStateDidChangeListener { [weak self] _ , user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }
    
    
    
    func creatAccount(email: String,
                      password: String,
                      nameAdmin: String,
                      nameCompany:String,
                      phone: String,
                      desc: String,
                      roomPassword: String) async throws {
        
        do {
            
            let result = try await Auth.auth().createUser(withEmail: email,
                                                   password: password)
            let uid = result.user.uid
            var dowloadURL: URL? = nil
            
            if let imageData = selectedImage,
            let uiImagedata = UIImage(data: imageData)?.jpegData(compressionQuality: 0.1) {
            let storage = Storage.storage().reference().child("/image/\(result.user.uid)")
            _ = try await storage.putDataAsync(uiImagedata)
            dowloadURL = try await storage.downloadURL()
                
            } else { }
            
            
            let admin = Company_Model(id: uid,
                                      adminID: uid,
                                   name: nameAdmin,
                                   companyName: nameCompany,
                                    adress: "",
                                   email: email,
                                   phone: phone,
                                    description: desc,
                                      image: dowloadURL?.absoluteString ?? "", 
                                      procedure: [],
                                      likes: 0,
                                      fcnTokenUser: fcnTokenUser,
                                      latitude: locationManager.userLatitude, 
                                      longitude: locationManager.userLongitude,
                                      categories: "")
          
            try await Admin_DataBase.shared.setCompanyForAdmin(admin: admin)
            
        } catch { print("creatAccount", error.localizedDescription.lowercased()) }
    }
    
    func signIn(email: String, password: String) async throws -> Bool {
        
        do {
            try await auth.signIn(withEmail: email,
                                         password: password)
            guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not correct uid", code: 0)}
            
            let admin = try await Admin_DataBase.shared.fetchAdmiProfile()
            if uid == admin.id {
                return true
            } else { return false}
            
        } catch {
            print("signIn", error.localizedDescription)
            return false
        }

    }
    
    func resetPasswors() async throws {
        Auth.auth().sendPasswordReset(withEmail: signInViewModel.email) { error in
            if let error = error {
                self.message = error.localizedDescription
            } else {
                self.message = "Ссылка для сброса отправлена на \(self.signInViewModel.email)"
            }
            self.showAlert = true
        }
    }
    
    
    func signOut() async {
        
        do {
            try auth.signOut()
            self.currentUser = nil
        } catch {
            print("DEBUG: SignOut Error...", error.localizedDescription)
        }
    }
    
    
    func saveAdminCompany() async -> Bool {
        
        do {
            
            try await creatAccount(email: signInViewModel.email,
                  
                                   password: signInViewModel.password,
                                   nameAdmin: signInViewModel.fullName,
                                   nameCompany: signInViewModel.nameCompany,
                                   phone: signInViewModel.phone, 
                                   desc: signInViewModel.textEditorDescrt,
                                   roomPassword: signInViewModel.adress)
            return true
        } catch {
            print("Error saveAdminCompany", error.localizedDescription)
            return false
        }
        
    }
 
}
