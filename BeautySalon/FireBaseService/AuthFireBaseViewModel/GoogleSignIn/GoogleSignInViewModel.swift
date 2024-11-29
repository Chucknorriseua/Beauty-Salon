//
//  GoogleSignInViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/10/2024.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth

@MainActor
final class GoogleSignInViewModel: ObservableObject {
    
    static var shared = GoogleSignInViewModel()
    
    
    @Published var isLogin: Bool = false
    @Published var emailGoogle: String? = ""
    @Published var idProfile = ""
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
    
    
    private func loadUserProfile(coordinator: CoordinatorView) async throws {
        let db = Firestore.firestore()
        
        let profile: [(String, String)] = [("BeautySalon", "Admin"), ("Master", "Master"), ("Client", "Client")]
        for (collectioName, profile) in profile {
            let snapshot = try await db.collection(collectioName).whereField("email", isEqualTo: self.emailGoogle ?? "").getDocuments()
            if snapshot.documents.first != nil { 
                
                self.idProfile = profile
                DispatchQueue.main.async {
                    
                self.goConntrollerProfile(coordinator: coordinator)
                }
                return
            }
        }
        DispatchQueue.main.async { coordinator.push(page: .google) }
    }
    
     func goConntrollerProfile(coordinator: CoordinatorView) {
        switch self.idProfile {
        case "Admin":
            Task {
               await AdminViewModel.shared.fetchProfileAdmin()
                coordinator.push(page: .Admin_main)
            }
        case "Master":
            Task {
             await MasterViewModel.shared.getCompany()
                 coordinator.push(page: .Master_Select_Company)
            }
        case "Client":
            Task {
            await ClientViewModel.shared.fetchAll_Comapny()
                 coordinator.push(page: .User_Main)
            }
        default: break
        }
    }
    
    func logOut() async throws {
        isLogin = false
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
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
