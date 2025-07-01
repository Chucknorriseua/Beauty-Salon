//
//  CoordinatorViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 28/08/2024.
//

import SwiftUI


struct CoordinatorViewModel: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    @StateObject private var coordinator = CoordinatorView()
    @StateObject private var google = GoogleSignInViewModel()
    @StateObject private var storeKitView = StoreViewModel()
    @StateObject private var banner = InterstitialAdViewModel()
    @StateObject private var apple = AppleAuthViewModel(coordinator: CoordinatorView(), isNotUseCoordinator: false)
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.Adminbuild(page: .main)
                .navigationDestination(for: PageAll.self) { page in
                    coordinator.Adminbuild(page: page)
                }
        }
        .onChange(of: scenePhase, { _, newValue in
            switch newValue {
            case .background:
                print("background")
                DispatchQueue.main.async {
                    firstSignIn = false
                }
            case .inactive:
                print("inactive")
            case .active:
                print("active")
                if !storeKitView.checkSubscribe {
                    Task {
                        await storeKitView.updateCustomerProductStatus()
                    }
                }
            @unknown default:
                print("default")
            }
        })
        .environmentObject(coordinator)
        .environmentObject(storeKitView)
        .environmentObject(google)
        .environmentObject(apple)
        .environmentObject(banner)
    }
}

