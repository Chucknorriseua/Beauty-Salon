//
//  UserMainForSheduleController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 03/10/2024.
//

import SwiftUI

struct UserMainForSheduleController: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @ObservedObject  var clientViewModel: ClientViewModel
    @EnvironmentObject var storeKitView: StoreViewModel
    @EnvironmentObject var banner: InterstitialAdViewModel
    
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    
    @State private var isShowSheet: Bool = false
    @State private var isSignUp: Bool = false
    @State private var isShowSubscription: Bool = false
   
    var body: some View {
        GeometryReader { geo in
            
            VStack(alignment: .center, spacing: 0) {
                
                VStack {
                    User_AdminViewProfile(clientViewModel: clientViewModel)
                }.padding(.bottom, -10)
                
                VStack {
                    UserMainSelectedMaster(clientViewModel: clientViewModel)
                }
                
            }
            .onAppear {
                if !firstSignIn {
                    withAnimation(.easeOut(duration: 1)) {
                        if !storeKitView.checkSubscribe {
                            isShowSubscription = true
                        }
                    }
                    if !storeKitView.checkSubscribe {
                     
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if let rootVC = UIApplication.shared.connectedScenes
                                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                                .first {
                                banner.showAd(from: rootVC)
                            }
                        }
                    }
                }
            }
                .customAlert(isPresented: $clientViewModel.isAlert, hideCancel: true, message: clientViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
                .createBackgrounfFon()
                .overlay(alignment: .center, content: {
                    if isShowSubscription {
                        StoreKitBuyAdvertisement(isXmarkButton: $isShowSubscription)
                    }
                })
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
                        .presentationDetents([.height(660)])
//                        .interactiveDismissDisabled()
                })
                .sheet(isPresented: $isShowSheet, content: {
                    UserSettings(isDeleteMyProfile: .constant(false), isShowDeleteButton: false, isShowSubscription: $isShowSubscription, clientViewModel: clientViewModel)
                        .presentationDetents([.height(360)])
//                        .interactiveDismissDisabled()
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

   
        }
    }
}
