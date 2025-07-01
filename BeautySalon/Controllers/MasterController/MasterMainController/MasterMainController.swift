//
//  MasterMainController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

struct MasterMainController: View {
    
    @EnvironmentObject var storeKitView: StoreViewModel
    @EnvironmentObject var banner: InterstitialAdViewModel
    @ObservedObject var masterViewModel: MasterViewModel
    @ObservedObject var VmCalendar: MasterCalendarViewModel
    @EnvironmentObject var coordinator: CoordinatorView
    @AppStorage("selectedAdmin") private var selectedAdminID: String?
    @State private var isShowSubscription: Bool = false
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
 
    var body: some View {
        NavigationView(content: {
            GeometryReader { geo in
                
                VStack {
                    VStack {
                        
                        ShedulMasterHeader(masterCalendarViewModel: VmCalendar)
                    }
                    .padding(.bottom, -20)
                    
                    ScrollView {
                        
                        ShedulCell(masterViewModel: VmCalendar, currentDate: VmCalendar.currentDate)
                            .padding(.bottom, 80)
                        
                    }
                    .scrollIndicators(.hidden)
                
                }
                .createBackgrounfFon()
                .overlay(alignment: .bottom) {
                    VStack {
                        if !storeKitView.checkSubscribe {
                            Banner()
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(.bottom, 80)
                }
          
                .overlay(alignment: .center, content: {
                    if isShowSubscription {
                        StoreKitBuyAdvertisement(isXmarkButton: $isShowSubscription)
                    }
                })
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        TabBarButtonBack {
                            selectedAdminID = nil
                            coordinator.push(page: .Master_Select_Company)
                        }
                    }
                })
                    .customAlert(isPresented: $masterViewModel.isAlert, hideCancel: true, message: masterViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
                
            }
        })
        .task {
            await masterViewModel.getCompany()
        }
        .onAppear {
            VmCalendar.setupWeeks()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
            Task {
              await VmCalendar.getSheduleMaster()
            }
        }
        .refreshable {
            await VmCalendar.getSheduleMaster()
        }
    }
}
