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
    @State private var isLoader: Bool = false
    @State private var loader: String = "Loading"

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 0) {
                User_FavoritesSalonView(isLoader: $isLoader)
                User_FavoritesMasterView()
            }
            .padding(.horizontal, 10)
            Spacer()
        }
        .createBackgrounfFon()
        .overlay(alignment: .center) {CustomLoader(isLoader: $isLoader, text: $loader)}
        .customAlert(isPresented: $clientVM.isAlert, hideCancel: true, message: clientVM.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                TabBarButtonBack {
                    coordinator.pop()
                }
            }
        })
    }
}

#Preview {
    User_MyFavorites()
}
