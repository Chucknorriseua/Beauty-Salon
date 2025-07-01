//
//  User_AdminView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 12/01/2025.
//

import SwiftUI


struct User_PriceList: View {
    
    @ObservedObject var clientViewModel = ClientViewModel.shared
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var storeKitView: StoreViewModel
    @EnvironmentObject var banner: InterstitialAdViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(clientViewModel.adminProfile.procedure) { priceList in
                            User_PriceListCell(procedure: priceList)
                                .padding(.vertical, 4)
                        }
                        Text("Home care")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.yellow)
                            .padding(.top, 20)
                        
                        ForEach(clientViewModel.homeCareSalon, id: \.self) { homeCare in
                            VStack {
                                HomeCareCell(homeCare: homeCare, isShow: false)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .onAppear {
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
            .frame(width: geo.size.width, height: geo.size.height)
            .foregroundStyle(Color.yellow.opacity(0.8))
            .overlay(alignment: .bottom) {
                if !storeKitView.checkSubscribe {
                    Banner()
                        .frame(maxWidth: .infinity, maxHeight: 120)
                        .padding(.horizontal, 12)
                }
            }
            .createBackgrounfFon()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        coordinator.pop()
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Price list for services")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.yellow)
                    }
                }
            }
        }
    }
}

#Preview(body: {
    User_PriceList(clientViewModel: ClientViewModel.shared)
})
