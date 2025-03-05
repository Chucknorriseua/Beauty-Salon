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
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                VStack {
                    Text("Price list for services")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.yellow)
                }
                
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
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .foregroundStyle(Color.yellow.opacity(0.8))
            .createBackgrounfFon()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        coordinator.pop()
                    }
                }
            }
        }
    }
}

#Preview(body: {
    User_PriceList(clientViewModel: ClientViewModel.shared)
})
