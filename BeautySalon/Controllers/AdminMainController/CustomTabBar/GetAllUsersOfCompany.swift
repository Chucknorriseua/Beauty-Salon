//
//  Informations.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct GetAllUsersOfCompany: View {
    
    @ObservedObject var adminViewModel: AdminViewModel
    @EnvironmentObject var storeKitView: StoreViewModel
    
    // MARK: Fetch all User Of Company
    var body: some View {
        NavigationView {
            
            VStack {
                Text("My Сlients")
                    .font(.system(.title, design: .serif, weight: .regular))
                    .foregroundStyle(Color.yellow)
                
                ScrollView {
                    LazyVStack(alignment: .center) {
                        
                        ForEach(adminViewModel.client, id:\.self) { user in
                            CellUser(clientModel: user)
                            
                        }
                        
                    }.padding(.top, 10)
                    
                }.scrollIndicators(.hidden)
                
            }
            .overlay(alignment: .bottom) {
                if !storeKitView.checkSubscribe {
                    Banner(adUnitID: "ca-app-pub-1923324197362942/6504418305")
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .padding(.horizontal, 12)
                }
            }
            .createBackgrounfFon()
            .refreshable {
                Task {
                    await adminViewModel.fetchCurrentClient()
                }
            }
        }
        
    }
}
