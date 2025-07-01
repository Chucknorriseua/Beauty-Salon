//
//  MapViewInfo.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 11/02/2025.
//

import SwiftUI

struct MapViewInfo: View {
    
    @State private var isLocationAlarm: Bool = false
    @State private var massage: String = ""
    @State private var title: String = ""
    
    
    @EnvironmentObject var storeKitView: StoreViewModel
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var banner: InterstitialAdViewModel
    @ObservedObject private var adminViewModel = AdminViewModel.shared
    @EnvironmentObject var coordinator: CoordinatorView
    
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                TabBarButtonBack {
                    coordinator.pop()
                }
                Spacer()
            }
            .padding(.leading, 14)
            VStack(spacing: 50) {
                
                Image("MapImageLocation")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .clipShape(.rect(cornerRadius: 24))
                    .padding(.horizontal, 40)
                
                Text("“Update your geolocation to the address of your salon so that masters and clients can find you.”")
                    .foregroundStyle(Color.white)
                    .fontWeight(.heavy)
                    .fontDesign(.monospaced)
                    .padding(.horizontal, 10)
                
                Button {
                    isLocationAlarm = true
                    massage = "Do you really want to update your location?"
                    title = "Change you'r location?"
                } label: {
                    HStack {
                        Text("Change geolocation")
                        Image(systemName: "location.fill")
                            .font(.system(size: 24))
                        
                    }.padding(.all, 4)
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .foregroundStyle(Color.white)
                        .background(Color.blue.opacity(0.6), in: .rect(cornerRadius: 24))
                        .padding(.horizontal, 8)
                }
                Spacer()
            }
            .customAlert(isPresented: $isLocationAlarm, hideCancel: true, message: massage, title: title, onConfirm: {
                Task { await locationManager.updateLocation(company: adminViewModel.adminProfile) }
            }, onCancel: {})
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
        .createBackgrounfFon()
    }
}
