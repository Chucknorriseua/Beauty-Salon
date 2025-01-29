//
//  UserMainForSheduleController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 03/10/2024.
//

import SwiftUI

struct UserMainForSheduleController: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @StateObject  var clientViewModel = ClientViewModel()
    @State private var isShowSheet: Bool = false
    @State private var isSignUp: Bool = false
   
    var body: some View {
        GeometryReader { geo in
            
            VStack(alignment: .center, spacing: 0) {
                
                VStack {
                    User_AdminViewProfile(clientViewModel: clientViewModel)
                }.padding(.bottom, -10)
                
                VStack {
                    UserMainSelectedMaster(clientViewModel: clientViewModel)
                }
                
            }.background(Color.init(hex: "#3e5b47").opacity(0.9))
                .customAlert(isPresented: $clientViewModel.isAlert, hideCancel: true, message: clientViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
                .overlay(alignment: .bottom, content: {
                    VStack {
                        CustomButton(title: "Sign up") {
                            isSignUp = true
                        }
                    }
                })
                .sheet(isPresented: $isSignUp, content: {
                    UserSend_SheduleForAdmin(clientViewModel: clientViewModel)
                        .foregroundStyle(Color.white)
                        .presentationDetents([.height(600)])
//                        .interactiveDismissDisabled()
                })
                .sheet(isPresented: $isShowSheet, content: {
                    UserSettings(clientViewModel: clientViewModel)
                        .presentationDetents([.height(260)])
                        .interactiveDismissDisabled()
                })
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        TabBarButtonBack {
                            coordinator.pop()
                        }
                    }
                })
                .foregroundStyle(Color.white)
                .tint(.yellow)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {isShowSheet = true} label: {
                            HStack(spacing: -8) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 18))
                            }.foregroundStyle(Color.white)
                        }

                    }
                })
                .foregroundStyle(Color.white)
                .tint(.yellow)
   
        }.refreshable {
            Task {
                await clientViewModel.fetchAllMasters_FromAdmin()
            }
        }
    }
}
