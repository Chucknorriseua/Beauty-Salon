//
//  Main_Controller_Register.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct Main_Controller_Register: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @State private var isShowReset: Bool = false
    
    var body: some View {
        
        VStack {
            VStack(alignment: .center, spacing: -20) {
                
                MainButtonSignIn(image: "person.wave.2.fill", title: " Create Salon") {coordinator.push(page: .Admin_Register)}
                
                MainButtonSignIn(image: "rectangle.portrait.and.arrow.right.fill", title: " Register as Master") {coordinator.push(page: .Master_Register)}
                
                MainButtonSignIn(image: "person.crop.square.fill", title: "Register as Client") {coordinator.push(page: .User_Register)}
                
                MainButtonSignIn(image: "lock.open.rotation", title: "Reset password") {
                    isShowReset = true
                }
            }
            .padding()
            
            Button {
                coordinator.pop()
            } label: {
                Image(systemName: "arrow.left.to.line")
                Text("Back to Sign In")
            }.foregroundStyle((Color.white))
                .font(.title2.bold())
            
        }
        .navigationBarTitleDisplayMode(.inline).toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create profile")
                    .foregroundStyle(Color.yellow.opacity(0.8))
                    .font(.system(size: 27, weight: .heavy).bold())
            }
        }
        .createBackgrounfFon()
        .sheet(isPresented: $isShowReset, content: {
            PasswordResetView()
        })
    }
}
