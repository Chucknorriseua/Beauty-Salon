//
//  AppleButtonView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 23/02/2025.
//

import SwiftUI
import AuthenticationServices
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CryptoKit


struct AppleButtonView: UIViewRepresentable {
    typealias UIViewType = ASAuthorizationAppleIDButton
    
    @EnvironmentObject var coordinator: CoordinatorView
    @State var isNotUseCoordinator: Bool
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        authorizationButton.addTarget(context.coordinator, action: #selector(AppleAuthViewModel.handleSignInWithApple), for: .touchUpInside)
        return authorizationButton
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    func makeCoordinator() -> AppleAuthViewModel {
        return Coordinator(coordinator: coordinator, isNotUseCoordinator: isNotUseCoordinator)
    }
}

class AppleAuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    @Published var coordinator: CoordinatorView
    private var currentNonce: String?
    @AppStorage("useRole") var useRole: String = ""
    @AppStorage("appleEmail") var appleEmail: String = ""
    @AppStorage("appleID") var appleID: String = ""
    @AppStorage("isAppleDelete") var isAppleDelete: Bool = false
    @AppStorage("isSubscribe") var isSubscribe: Bool = false
    @Published var isNotUseCoordinator: Bool
  

    init(coordinator: CoordinatorView, isNotUseCoordinator: Bool) {
        self.coordinator = coordinator
        self.isNotUseCoordinator = isNotUseCoordinator
    }
    
    @objc func handleSignInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        print("Generated Nonce: \(nonce)") // Добавь для отладки

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        guard let token = appleIDCredential.identityToken else {
            print("Ошибка: identityToken не найден")
            return
        }

        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("Ошибка: не удалось преобразовать токен в строку")
            return
        }

        guard let nonce = currentNonce else {
            print("Ошибка: nonce отсутствует")
            return
        }

        let firebaseCredential = OAuthProvider.credential(providerID: .apple, idToken: tokenString, rawNonce: nonce)

        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                print("Ошибка входа в Firebase: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else { return }
      
            print("Вход выполнен: \(user.uid)")
            DispatchQueue.main.async {
                self.appleEmail = user.email ?? ""
                self.appleID = user.uid
            }
            Task {
                if self.isNotUseCoordinator {
                    DispatchQueue.main.async {
                        self.isAppleDelete = true
                    }
                    print("isNotUseCoordinator")
                } else {
                    try await self.loadUserProfile(coordinator: self.coordinator)
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let nsError = error as NSError
        if nsError.code == ASAuthorizationError.canceled.rawValue {
            print("Пользователь отменил вход через Apple")
            DispatchQueue.main.async {
                self.isAppleDelete = false
            }
            return
        }
        print("Ошибка авторизации через Apple: \(error.localizedDescription)")
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first ?? UIWindow()
        }
        return UIWindow()
    }

    // Генерация случайного nonce
    func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if status == errSecSuccess {
                    return random
                } else {
                    return 0
                }
            }

            for random in randoms {
                if remainingLength == 0 {
                    break
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    @MainActor
    func signOutFromAppleBeforeGoogle() {
            self.appleID = ""
            self.appleEmail = ""
            self.useRole = ""
            self.objectWillChange.send()
        print("✅ Данные Apple ID очищены, теперь можно заходить через Google")
    }
    
    @MainActor
    func loadUserProfile(coordinator: CoordinatorView) async throws {
        let db = Firestore.firestore()
        
        let profiles: [(String, String)] = [("BeautySalon", "Admin"), ("Master", "Master"), ("Client", "Client")]
        
        for (collectionName, role) in profiles {
            let snapshot = try await db.collection(collectionName).whereField("email", isEqualTo: self.appleEmail).getDocuments()
            
            if snapshot.documents.first != nil {
                self.useRole = role
               Task {
                  await self.goConntrollerProfile(coordinator: coordinator)
                }
                return
            }
        }
 
        DispatchQueue.main.async {
            coordinator.push(page: .apple)
        }
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
        default:
            break
        }
    }
}
