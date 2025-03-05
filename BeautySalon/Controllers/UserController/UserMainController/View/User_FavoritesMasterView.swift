//
//  User_FavoritesMasterView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 23/02/2025.
//

import SwiftUI

struct User_FavoritesMasterView: View {
    
    @ObservedObject var clientVM = ClientViewModel.shared
    
    var body: some View {
        VStack {
            Text("My favorites Master")
                .foregroundStyle(Color.yellow)
                .font(.system(size: 24, weight: .bold))
                .fontDesign(.serif)
                .underline(color: .yellow)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(clientVM.masterFavorites, id: \.id) { master in
                        NavigationLink(destination: AddNewMasterView(isShowButtonAdd: false, isShowPricelist: true, addMasterInRoom: master, isShowMasterSend: false, isShowSendButton: true).navigationBarBackButtonHidden(true)) {
                            User_FavoritesMasterCell(master: master)
                             
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: 200)

        }
        .frame(maxWidth: .infinity)
        .onAppear {
            Task {
                await clientVM.fetchFavoritesMaster()
            }
        }
    }
}

#Preview {
    User_FavoritesMasterView()
}
