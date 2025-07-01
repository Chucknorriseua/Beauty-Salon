//
//  GoogleSignInViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/10/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuth

@MainActor
final class GoogleSignInViewModel: ObservableObject {
    
    static var shared = GoogleSignInViewModel()
    
    
    @Published var isLogin: Bool = false
    @Published var emailGoogle: String? = ""
    @Published var isSubscribe: Bool = false
    @Published var isDeleteGoogle: Bool = false

    @AppStorage("useRole") var useRole: String = ""
    @AppStorage("appleEmail") var appleEmail: String = ""
    @AppStorage("appleID") var appleID: String = ""
    @Published var idGoogle = ""
    
    init() {}
    
    func signInWuthGoogle(coordinator: CoordinatorView) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_untill.rootViewController) {[weak self] user, error in
            guard let self else { return }
            if let error = error {
                self.isLogin = false
                if (error as NSError).code == GIDSignInError.canceled.rawValue {
                    print("Failed canceled with google...", error.localizedDescription)
                }
                print(error.localizedDescription)
            }
            
            guard let user = user?.user, let idToken = user.idToken else { return }
            let accesToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accesToken.tokenString)
            
            Auth.auth().signIn(with: credential) {  res, error in
                
                if let error = error {
                    self.isLogin = false
                    print(error.localizedDescription)
                }
                guard let user = res?.user else { return }
                self.isLogin = true
                self.idGoogle = user.uid
                self.emailGoogle = user.email ?? ""
                Task {
                    do {
                      try await self.loadUserProfile(coordinator: coordinator)
                    } catch {
                        print("Failed login with google...", error.localizedDescription)
                        self.isLogin = false
                    }
                }
            }
        }
    }
    
    func signInWuthGoogleAuth() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_untill.rootViewController) {[weak self] user, error in
            guard let self else { return }
            if let error = error {
                self.isLogin = false
                print(error.localizedDescription)
            }
            
            guard let user = user?.user, let idToken = user.idToken else { return }
            let accesToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accesToken.tokenString)
            
            Auth.auth().signIn(with: credential) {  res, error in
                
                if let error = error {
                    self.isLogin = false
                    print(error.localizedDescription)
                }
//                guard let user = res?.user else { return }
                self.isLogin = true
                self.isDeleteGoogle = true

            }
        }
    }
    
    func checkSubscribeGoogleProfile(coordinator: CoordinatorView) async throws  {
        appleEmail = ""
        appleID = ""
        if isLogin {
        await goConntrollerProfile(coordinator: coordinator)
        } else {
         signInWuthGoogle(coordinator: coordinator)
        }
    }
    
    
    private func loadUserProfile(coordinator: CoordinatorView) async throws {
        let db = Firestore.firestore()
        
        let profile: [(String, String)] = [("BeautySalon", "Admin"), ("Master", "Master"), ("Client", "Client")]
        for (collectioName, profile) in profile {
            let snapshot = try await db.collection(collectioName).whereField("email", isEqualTo: self.emailGoogle ?? "").getDocuments()
            if snapshot.documents.first != nil { 
                
                self.useRole = profile
               Task {
                    
               await self.goConntrollerProfile(coordinator: coordinator)
                }
                return
            }
        }
        DispatchQueue.main.async { coordinator.push(page: .google) }
    }
    
    @MainActor
     func goConntrollerProfile(coordinator: CoordinatorView) async {
        switch self.useRole {
        case "Admin":
            await AdminViewModel.shared.fetchProfileAdmin()
            coordinator.push(page: .Admin_main)
//            if StoreViewModel.shared.checkSubscribe {
//                await AdminViewModel.shared.fetchProfileAdmin()
//                coordinator.push(page: .Admin_main)
//            } else {
//                DispatchQueue.main.async {
//                    self.isSubscribe = true
//                }
//            }
        case "Master":
            await MasterViewModel.shared.fetchProfile_Master()
            coordinator.push(page: .Master_Select_Company)
//            if StoreViewModel.shared.checkSubscribe {
//                await MasterViewModel.shared.fetchProfile_Master()
//                coordinator.push(page: .Master_Select_Company)
//            } else {
//                DispatchQueue.main.async {
//                    self.isSubscribe = true
//                }
//            }
        case "Client":
            await ClientViewModel.shared.fetchAll_Comapny()
            coordinator.push(page: .User_Main)
        default: break
        }
    }
    
    func logOut() async throws {
        isLogin = false
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        try await GIDSignIn.sharedInstance.disconnect()
    }
    
    deinit {
    }
}

final class Application_untill {
    
    static var rootViewController: UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .init()}
        
        guard let root = screen.windows.first?.rootViewController else { return .init()}
        
        return root
    }
}
