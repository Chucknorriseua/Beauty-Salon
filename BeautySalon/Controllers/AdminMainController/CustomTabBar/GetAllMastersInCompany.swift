//
//  ClientView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct GetAllMastersInCompany: View {
    
    @ObservedObject var adminViewModel: AdminViewModel
    @EnvironmentObject var storeKitView: StoreViewModel
    
    var body: some View {
        NavigationView {
                VStack {
                    Text("Send schedule for master")
                        .font(.system(.title, design: .serif, weight: .regular))
                        .foregroundStyle(Color.yellow)
                    ScrollView {
                        
                        LazyVStack {
                            //  MARK: Shedul For Master Calendar
                            ForEach(adminViewModel.addMasterInRoom, id: \.id) { item in
                                NavigationLink(destination: AdminAddForMasterShedule(adminViewModel: adminViewModel,
                                                                                     masterModel: item).navigationBarBackButtonHidden(true)) {
                                    CellMaster(masterModel: item)

                                }
                            }
                            
                        }.padding(.top, 10)
                    }.scrollIndicators(.hidden)
                        .refreshable {
                            Task {
                                await adminViewModel.get_AllAdded_Masters_InRomm()
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
            
        }
    }
}
