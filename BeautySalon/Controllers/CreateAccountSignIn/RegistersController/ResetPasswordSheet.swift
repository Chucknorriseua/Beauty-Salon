//
//  ResetPasswordSheet.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 23/02/2025.
//

import SwiftUI

struct PasswordResetView: View {
    
    @StateObject private var adminAuth = Auth_ADMIN_Viewmodel()
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Password reset")
                .font(.largeTitle)
                .foregroundStyle(Color.yellow)
                .bold()
                .padding()

            CustomTextField(text: $adminAuth.signInViewModel.email, title: "Enter your email", width: .infinity, showPassword: .constant(true))
                .keyboardType(.emailAddress)

            CustomButton(title: "Send reset link") {
                resetPassword()
                dismiss()
            }

            Text(adminAuth.message)
                .foregroundColor(.white)
                .padding()
        }
        .createBackgrounfFon()
        .customAlert(isPresented: $adminAuth.showAlert, hideCancel: false, message: adminAuth.message, title: "", onConfirm: {
            
        }, onCancel: {})

    }
    
    private func resetPassword() {
        guard !adminAuth.signInViewModel.email.isEmpty else {
            adminAuth.message = "Enter your email"
            adminAuth.showAlert = true
            return
        }
        Task {
            do {
               try await adminAuth.resetPasswors()
            } catch {
                adminAuth.message = "Incorrect email."
            }
        }
    }
}


#Preview {
    PasswordResetView()
}
