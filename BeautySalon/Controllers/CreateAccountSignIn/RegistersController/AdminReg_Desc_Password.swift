//
//  AdminReg_Desc_Password.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/09/2024.
//

import SwiftUI

struct AdminReg_Desc_Password: View {
    
    @StateObject var authViewModel = Auth_ADMIN_Viewmodel()
    @StateObject var adminViewModel: AdminViewModel
    @EnvironmentObject var coordinator: CoordinatorView
    @State private var isEditor: Bool = false
    @State private var loader: String = "Loader"
    @State private var isLoader: Bool = false
    
    var body: some View {
        
        VStack {
            VStack(alignment: .center, spacing: 40) {
                
                Text("Enter the address where your salon is located, describe briefly about the salon and what it does")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 24, weight: .bold))
                
                CustomTextField(text: $adminViewModel.adminProfile.adress,
                                title: "Adress", width: UIScreen.main.bounds.width - 20,
                                showPassword:  $authViewModel.signInViewModel.showPassword)
                
                
                
                Text("Describe your company, what you do, what services you provide")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 20, weight: .bold))
                
                VStack {
                    
                    TextEditor(text: $adminViewModel.adminProfile.description)
                        .foregroundStyle(Color(hex: "F3E3CE"))
                        .frame(width: 380, height: 180)
                        .scrollContentBackground(.hidden)
     
                }.background(.ultraThinMaterial.opacity(0.8))
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.leading, 6)
                    .padding(.trailing, 6)
                
                CustomButton(title: "Save") {
                    isLoader = true
                    
                    Task {
                        await adminViewModel.setNew_Admin_Profile()
                        coordinator.popToRoot()
                        isLoader = false
                    }
                }.opacity(isFarmValid ? 1 : 0.5)
                .disabled(!isFarmValid)
                
            }.padding(.leading, 4)
                .padding(.trailing, 4)
            
        }.createBackgrounfFon()
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        coordinator.pop()
                    }
                }
            }).navigationBarBackButtonHidden(true)
            .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
            .onAppear {
                Task {
                    await adminViewModel.fetchProfileAdmin()
                }
            }
    }
}
extension AdminReg_Desc_Password: isFormValid {
    var isFarmValid: Bool {
        return authViewModel.signInViewModel.textEditorDescrt.count < 200
  
    }
    
    
}
