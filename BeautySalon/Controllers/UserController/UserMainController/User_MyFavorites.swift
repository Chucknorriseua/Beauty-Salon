//
//  User_MyFavorites.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 22/02/2025.
//

import SwiftUI

struct User_MyFavorites: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @ObservedObject var clientVM = ClientViewModel.shared
    @EnvironmentObject var storeKitView: StoreViewModel
    @EnvironmentObject var banner: InterstitialAdViewModel

    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    
    @State private var isLoader: Bool = false
    @State private var isDeleteProf: Bool = false
    @State private var isShowSheet: Bool = false
    @State private var isShowSubscription: Bool = false
    @State private var loader: String = "Loading"
    @State private var massage: String = "Once your profile has been deleted, it can no longer be restored"
    @State private var title: String = "Do you really want to delete your profile?"
    @State private var deleteShedule: Shedule?

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    VStack(alignment: .center, spacing: 10) {
                        User_FavoritesSalonView(clientVM: clientVM, isLoader: $isLoader)
                        User_FavoritesMasterView(clientVM: clientVM)
                        User_MyRecords(clientVM: clientVM, deleteRecods: $deleteShedule)
                    }
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
        }
        .overlay(alignment: .bottom) {
            if !storeKitView.checkSubscribe {
                Banner(adUnitID: "ca-app-pub-1923324197362942/6504418305")
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .padding(.horizontal, 12)
            }
        }
        .createBackgrounfFon()
        .sheet(isPresented: $isShowSheet, content: {
            UserSettings(isDeleteMyProfile: $isDeleteProf, isShowDeleteButton: true, isShowSaveButtonFavorites: true, isShowSubscription: $isShowSubscription, clientViewModel: clientVM)
                .presentationDetents([.height(400)])
        })
        .overlay(alignment: .center) {CustomLoader(isLoader: $isLoader, text: $loader)}
        .overlay(alignment: .center, content: {
            if isShowSubscription {
                StoreKitBuyAdvertisement(isXmarkButton: $isShowSubscription)
            }
        })
        .customAlert(isPresented: $clientVM.isAlert, hideCancel: true, message: clientVM.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
        .customAlert(isPresented: $clientVM.isDeleteRecords, hideCancel: true, message: "If you delete an entry scheduled for tomorrow or later, you will not receive notifications about it.", title: "Delete the record?", onConfirm: {
            Task {
                await clientVM.removeMyrecords(record: deleteShedule ?? Shedule.sheduleModel())
            }
        }, onCancel: {
            deleteShedule = nil
        })
        .customAlert(isPresented: $isDeleteProf, hideCancel: true, message: massage,title: title, onConfirm: {
            Task {
                try await Client_DataBase.shared.deleteMyProfileFromFirebase(profile: clientVM.clientModel)
                coordinator.popToRoot()
            }
        }, onCancel: {})
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                TabBarButtonBack {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("My favorites Salon")
                    .foregroundStyle(Color.yellow)
                    .font(.system(size: 24, weight: .bold))
                    .fontDesign(.serif)
                    .underline(color: .yellow)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {isShowSheet = true} label: {
                    HStack(spacing: -8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                    }.foregroundStyle(Color.white)
                }
            }
        })
    }
}
