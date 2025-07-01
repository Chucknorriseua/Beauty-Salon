//
//  User_FavoritesSalonView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 23/02/2025.
//

import SwiftUI

struct User_FavoritesSalonView: View {
    
    @ObservedObject var clientVM: ClientViewModel
    @EnvironmentObject var coordinator: CoordinatorView
    @Binding var isLoader: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(clientVM.salonFavorites, id: \.id) { salon in
                        Button {
                            isLoader = true
                            Task {
                                clientVM.isFetchDataLoader = false
                                clientVM.adminProfile.adminID = salon.adminID
                                await clientVM.fetchCurrent_AdminSalon(adminId: salon.adminID)
                                await MainActor.run {
                                    if clientVM.isFetchDataLoader {
                                        coordinator.push(page: .User_SheduleAdmin)
                                    }
                                    isLoader = false
                                }
                            }
                        } label: {
                            Use_FavoritesSalonCell(salon: salon)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .frame(height: 200)
        .onAppear {
            Task {
                await clientVM.fetchFavoritesSalon()
            }
        }
    }
}

//#Preview {
//    User_FavoritesSalonView()
//}
