//
//  Auth_ClientViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 03/10/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

@MainActor
final class Auth_ClientViewModel: ObservableObject {
    
    static var shared = Auth_ClientViewModel()
    
    @Published var locationManager = LocationManager()
    @Published var signInViewmodel = SignInViewModel()
    @Published var currentUser: User? = nil
    @AppStorage ("fcnTokenUser") var fcnTokenUser: String = ""
 
    
    let auth = Auth.auth()
    
    init(){
        _ = auth.addStateDidChangeListener { [weak self] _ , user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }
    
// MARK: Func Auth for Master
    
    func createAccount_Client(email: String, password: String, name: String, phone: String) async throws {
        do {
           let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            let client = Client(id: uid,
                                clientID: uid,
                                name: name,
                                email: email,
                                phone: phone,
                                date: Date(),
                                fcnTokenUser: fcnTokenUser,
                                latitude: locationManager.userLatitude,
                                longitude: locationManager.userLongitude,
                                shedule: [])
            try await Client_DataBase.shared.setData_ClientFireBase(clientModel: client)
        } catch {
            print("DEBUG: SING IN ERROR sign in Account as Client", error.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String) async throws -> Bool {

        do {
            try await auth.signIn(withEmail: email, password: password)
           _ = try await Client_DataBase.shared.fetchClient_DataFB()
            return true
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
         try await createAccount_Client(email: signInViewmodel.email,
                                 password: signInViewmodel.password,
                                 name: signInViewmodel.fullName,
                                 phone: signInViewmodel.phone)
            return true
        } catch {
            print("DEBUG SAVE Client: Error save client account", error.localizedDescription)
            return false
        }
    }
    
    func signOutClient() {
        do {
            try auth.signOut()
            self.currentUser = nil
        } catch {
            print("DEBUG: SignOut", error.localizedDescription)
        }
    }

    
}
