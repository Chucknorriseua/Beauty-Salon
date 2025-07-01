//
//  ClientForMastrer.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 02/09/2024.
//

import SwiftUI

struct ClientForMastrer: View {
    
    
    @ObservedObject var masterViewModel: MasterViewModel
    @ObservedObject var VmCalendar: MasterCalendarViewModel
    @EnvironmentObject var storeKitView: StoreViewModel
    
// MARK: Fetch all User Of Company
    var body: some View {
        NavigationView(content: {
                
                VStack {
                    Text("Clients for recording")
                        .font(.system(.title, design: .serif, weight: .regular))
                        .foregroundStyle(Color.yellow)
                    
                    ScrollView {
                        LazyVStack(alignment: .center) {
                            
                            ForEach(VmCalendar.client, id:\.self) { user in
                                CellUser(clientModel: user)
                            }
                            
                        }.padding(.top, 10)
                        
                    }.scrollIndicators(.hidden)
                        .refreshable {
                            Task {
                                await VmCalendar.fetchCurrentClient()
                            }
                        }
                }
                .overlay(alignment: .bottom) {
                    if !storeKitView.checkSubscribe {
                        VStack {
                            Banner(adUnitID: "ca-app-pub-1923324197362942/6504418305")
                                .frame(maxWidth: .infinity, maxHeight: 80)
                                .padding(.horizontal, 12)
                        }
                        .padding(.bottom, 60)
                    }
                }
                .createBackgrounfFon()
           
        })
    }
}
