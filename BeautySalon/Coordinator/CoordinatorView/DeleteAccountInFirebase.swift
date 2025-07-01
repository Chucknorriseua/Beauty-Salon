//
//  DeleteAccountInFirebase.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 21/03/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

struct DeleteAccountInFirebase: View {
    
    @EnvironmentObject var google: GoogleSignInViewModel
    @EnvironmentObject var coordinator: CoordinatorView
    @AppStorage("isAppleDelete") var isAppleDelete: Bool = false
    @AppStorage("appleEmail") var appleEmail: String = ""
    @AppStorage("appleID") var appleID: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertMessage: String = ""
    @State private var alertMessageApple: String = "Are you sure you want to delete your profile from My Beauty Hub? Once deleted, it can't be restored!"
    @State private var titleMessage: String = "Delete my Profile"
    @State private var succedMessage: String = "Your profile has been completely deleted"
    @State private var isShowAlert: Bool = false
    @State private var isSuccecDelete: Bool = false
    @State private var showPassword: Bool = false
  
  
    
    var body: some View {
        VStack(spacing: 50) {
            Text("You must be logged in to your account to delete your profile")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.white)
            
            VStack {
                CustomTextField(text: $email, title: "Email", width: UIScreen.main.bounds.width - 20, showPassword: $showPassword)
                CustomTextField(text: $password, title: "Password", width: UIScreen.main.bounds.width - 20, showPassword: $showPassword)
               
                VStack {
                    Button {
                        isShowAlert = true
                        alertMessage = "Are you sure you want to delete your profile from My Beauty Hub? Once deleted, it can't be restored!"
                    } label: {
                        Text("Delete my Profile")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .background(Color(red: 0.11, green: 0.14, blue: 0.12))
                            .clipShape(.rect(cornerRadius: 18, style: .continuous))
                    }
                    
                    VStack {
                        AppleButtonView(isNotUseCoordinator: true)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 56)
                    .clipShape(.rect(cornerRadius: 18, style: .continuous))
                    VStack {
                        Button {
                            Task {
                                alertMessage = "Are you sure you want to delete your profile from My Beauty Hub? Once deleted, it can't be restored!"
                                google.signInWuthGoogleAuth()
                            }
                        } label: {
                            HStack {
                                Image("google")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                Text("Sign In")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundStyle(Color.white)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .background(Color(red: 0.11, green: 0.14, blue: 0.12))
                            .clipShape(.rect(cornerRadius: 18, style: .continuous))
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 10)
            }
        }
        .createBackgrounfFon()
        .ignoresSafeArea(.keyboard)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                TabBarButtonBack {
                    coordinator.pop()
                }
            }
        })
        .customAlertWithImage(isPresented: $isShowAlert, hideCancel: true, message: alertMessage, title: titleMessage,  isShowImage: true, imageName: "profile") {
            Task {
                await reauthenticateAndDeleteUser(email: email, password: password)
            }
        } onCancel: {
            
        }
        .customAlertWithImage(isPresented: $isSuccecDelete, hideCancel: false, message: succedMessage, title: "", isShowImage: true, imageName: "check") {
            coordinator.popToRoot()
        } onCancel: {
            Task {
                try Auth.auth().signOut()
            }
        }
        .customAlertWithImage(isPresented: $google.isDeleteGoogle, hideCancel: true, message: alertMessage, title: titleMessage, isShowImage: true, imageName: "profile") {
            Task {
                if let currentUser = Auth.auth().currentUser {
                 if currentUser.providerData.first?.providerID == "google.com" {
                        await reauthenticateAndDeleteUserGoogle()
                    } else {
                        alertMessage = "User is not authenticated"
                    }
                }
            }
        } onCancel: {
            Task {
                try await google.logOut()
            }
        }
        .customAlertWithImage(isPresented: $isAppleDelete, hideCancel: true, message: alertMessageApple, title: titleMessage, isShowImage: true, imageName: "profile") {
            Task {
                if let currentUser = Auth.auth().currentUser {
                    if currentUser.providerData.first?.providerID == "apple.com" {
                        await reauthenticateAndDeleteUserApple()
                    } else {
                        alertMessage = "User is not authenticated"
                    }
                }
            }
        } onCancel: {
            appleID = ""
            appleEmail = ""
        }
    }
    @MainActor
    private func reauthenticateAndDeleteUserApple() async {
        do {
            guard let currentUser = Auth.auth().currentUser else {
                alertMessage = "User is not authenticated"
                isShowAlert = true
                return
            }

            if currentUser.providerData.first?.providerID == "apple.com" {
               
                await deleteUserByUID()
                try await currentUser.delete()

                alertMessage = "Your profile has been completely deleted"
                isSuccecDelete = true
            } else {
                alertMessage = "User not found. Check email or Wrong password Try again."
            }
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    private func reauthenticateAndDeleteUserGoogle() async {
        do {
            guard let currentUser = Auth.auth().currentUser else {
                alertMessage = "User is not authenticated"
                isShowAlert = true
                return
            }

            if currentUser.providerData.first?.providerID == "google.com" {
                await deleteUserByUID()
                try await currentUser.delete()

                alertMessage = "Your profile has been completely deleted"
                isSuccecDelete = true
            } else {
                alertMessage = "User not found. Check email or Wrong password Try again."
            }
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    private func reauthenticateAndDeleteUser(email: String, password: String) async {
        do {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)

            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = authResult.user
            try await user.reauthenticate(with: credential)
            await deleteUserByUID()
            try await user.delete()
            
            alertMessage = "Your profile has been completely deleted"
            isSuccecDelete = true
        } catch {
            alertMessage = "User not found. Check email or Wrong password Try again."
            isShowAlert = true
        }
    }

    @MainActor
    func deleteUserByUID() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Ошибка: пользователь не найден")
            return
        }
        
        let db = Firestore.firestore()
        
        do {
            // Проверка данных для администратора
            if let adminDoc = try await db.collection("BeautySalon").whereField("id", isEqualTo: uid).getDocuments().documents.first {
                print("Найден администратор с UID: \(uid)")
                let profile = try adminDoc.data(as: Company_Model.self)
                try await Admin_DataBase.shared.deleteMyProfileFromFirebase(profile: profile)
                alertMessage = "Your profile has been completely deleted"
                isSuccecDelete = true
                print("Удален администратор")
            }
            // Проверка данных для мастера
            else if let masterDoc = try await db.collection("Master").whereField("id", isEqualTo: uid).getDocuments().documents.first {
                print("Найден мастер с UID: \(uid)")
                let profile = try masterDoc.data(as: MasterModel.self)
                try await Master_DataBase.shared.deleteMyProfileFromFirebase(profile: profile)
                alertMessage = "Your profile has been completely deleted"
                isSuccecDelete = true
                print("Удален мастер")
            }
            // Проверка данных для клиента
            else if let clientDoc = try await db.collection("Client").whereField("id", isEqualTo: uid).getDocuments().documents.first {
                print("Найден клиент с UID: \(uid)")
                let profile = try clientDoc.data(as: Client.self)
                try await Client_DataBase.shared.deleteMyProfileFromFirebase(profile: profile)
                alertMessage = "Your profile has been completely deleted"
                isSuccecDelete = true
                print("Удален клиент")
            }
            else {
                print("Ошибка: Роль пользователя не определена")
            }
        } catch {
            print("Ошибка при определении роли или удалении данных: \(error.localizedDescription)")
        }
    }
}

#Preview {
    DeleteAccountInFirebase()
}
