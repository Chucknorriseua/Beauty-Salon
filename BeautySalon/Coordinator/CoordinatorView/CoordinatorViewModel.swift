//
//  CoordinatorViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 28/08/2024.
//

import SwiftUI

struct CoordinatorViewModel: View {
    
    @StateObject private var coordinator = CoordinatorView()
    @StateObject private var google = GoogleSignInViewModel()
    @StateObject private var storeKitView = StoreViewModel()
    @StateObject private var apple = AppleAuthViewModel(coordinator: CoordinatorView())
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.Adminbuild(page: .main)
                .navigationDestination(for: PageAll.self) { page in
                    coordinator.Adminbuild(page: page)
                }
        }
        .environmentObject(coordinator)
        .environmentObject(storeKitView)
        .environmentObject(google)
        .environmentObject(apple)
    }
}
