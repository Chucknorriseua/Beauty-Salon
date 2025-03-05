//
//  Auth_Master_ViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 29/08/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

@MainActor
final class Auth_Master_ViewModel: ObservableObject {
    
    static var shared = Auth_Master_ViewModel()
    
    @Published var locationManager = LocationManager()
    @Published var signInViewmodel = SignInViewModel()
    @Published var selectedImage: Data? = nil
    @Published var currentUser: User? = nil
    @Published var isShowAlert: Bool = false
    @Published var isShowSheet: Bool = false
    @AppStorage ("fcnTokenUser") var fcnTokenUser: String = ""
    
    let auth = Auth.auth()
    
    var storage_REF = Storage.storage().reference()
    
    init(){
        _ = auth.addStateDidChangeListener { [weak self] _ , user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }
    
    // MARK: Func Auth for Master
    
    func createAccount_Master(email: String,
                              password: String,
                              name: String,
                              phone: String) async throws {
        
        do {
            
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            
            var dowloadURL: URL? = nil
            
            if let imageData = selectedImage,
               let imageSize = UIImage(data: imageData)?.jpegData(compressionQuality: 0.1) {
                
                let storage = storage_REF.child("/masterImage/\(result.user.uid)")
                _ = try await storage.putDataAsync(imageSize)
                dowloadURL = try await storage.downloadURL()
                
                
            } else { }
            
            let master = MasterModel(id: uid,
                                     masterID: uid,
                                     name: name,
                                     email: email,
                                     phone: phone,
                                     description: "",
                                     image: dowloadURL?.absoluteString ?? "",
                                     imagesUrl: [], categories: "",
                                     fcnTokenUser: fcnTokenUser,
                                     likes: 0,
                                     procedure: [],
                                     latitude: locationManager.userLatitude,
                                     longitude: locationManager.userLongitude)
            
            try await Master_DataBase.shared.setData_For_Master_FB(master: master)
            
        } catch {
            isShowAlert = true
            print("DEBUG: MASTER Error Create master account", error.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String) async throws -> Bool {
        
        do {
            try await auth.signIn(withEmail: email, password: password)
            
            guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Error uid user not correct ", code: 0)}
            let master = try await Master_DataBase.shared.fecth_Data_Master_FB()
            if uid == master.id {
                return true
            } else {
                return false
            }
        } catch {
            print("DEBUG: SING IN ERROR sign in Account", error.localizedDescription)
            return false
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.currentUser = nil
        } catch {
            print("DEBUG: SignOut", error.localizedDescription)
        }
    }
    
    func saveAccount_Master() async -> Bool {
        do {
            try await createAccount_Master(email: signInViewmodel.email,
                                           password: signInViewmodel.password,
                                           name: signInViewmodel.fullName,
                                           phone: signInViewmodel.phone)
            isShowSheet = true
            return true
        } catch {
        print("DEBUG SAVE MASTER: Error save master account", error.localizedDescription)
        return false
        }
    }
}
