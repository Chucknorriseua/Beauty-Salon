//
//  MasterSelectedCompany.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 22/08/2024.
//

import SwiftUI

struct MasterSelectedCompany: View {
    
    @ObservedObject var masterViewModel = MasterViewModel.shared
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var banner: InterstitialAdViewModel
    @EnvironmentObject var storeKitView: StoreViewModel
    
    
    @AppStorage("selectedAdmin") private var selectedAdminID: String?
    @AppStorage("useRole") private var useRole: String = ""
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    
    
    @State private var selectedAdmin: String? = nil
    @State private var searchText: String = ""
    @State private var loader: String = "Loading"
    @State private var message: String = ""
    @State private var isTitle: String = ""
    @State private var isLoader: Bool = false
    @State private var isShowSubscription: Bool = false
    @State private var isShowMessage: Bool = false
    @State private var distance: Double = 10000
    
    
    
    private var searchCompanyNearby: [Company_Model] {
        SearchService.filterModels(models: masterViewModel.company,
                                   searchText: searchText,
                                   userLocation: locationManager.locationManager.location,
                                   radius: distance)
    }
    
    var body: some View {
        
        VStack {
            ScrollView {
                LazyVStack {
                    
                    ForEach(searchCompanyNearby, id:\.self) { company in
                        ZStack {
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    selectedAdmin = company.adminID
                                    let titleEnter = String(
                                        format: NSLocalizedString("enter_salon_format", comment: ""),
                                        company.companyName
                                    ).uppercased()
                                    isTitle = titleEnter
                                }
                            } label: {
                                CompanyAllCell(companyModel: company, isShow: selectedAdmin == company.id, isShowLike: false, isShowFavoritesSalon: true, onToggle: {})
                            }
                        }.customAlert(isPresented: Binding(get: { selectedAdmin == company.adminID }, set: { newValue in
                            if !newValue { selectedAdmin = nil }
                        }), hideCancel: true, message: message, title: isTitle) {
                            
                            Task {
                                await enterToSalon(company: company)
                            }
                            
                        } onCancel: {
                            selectedAdmin = nil
                            isTitle = ""
                            message = ""
                        }
                        .id(company)

                    }
                }.scrollTargetLayout()
                
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            if !firstSignIn {
                                withAnimation(.easeOut(duration: 1)) {
                                    if !storeKitView.checkSubscribe {
                                        isShowSubscription = true
                                    }
                                }
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
                        }
                    }
            
            }.scrollIndicators(.hidden)
         
                .refreshable {
                    Task {
                        await masterViewModel.getCompany()
                    }
                }
            if searchCompanyNearby.isEmpty {
                ContentUnavailableView("Salon not found...", systemImage: "house.lodge.circle.fill", description: Text("Please try again."))
            }
        }
        .createBackgrounfFon()
        .overlay(alignment: .bottom) {
            if !storeKitView.checkSubscribe {
                Banner(adUnitID: "ca-app-pub-1923324197362942/6504418305")
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .padding(.horizontal, 12)
            }
        }
        .overlay(alignment: .center, content: {
            if isShowSubscription {
                StoreKitBuyAdvertisement(isXmarkButton: $isShowSubscription)
            }
        })
        .customAlert(isPresented: $masterViewModel.isAlert, hideCancel: true, message: masterViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
        .swipeBack(coordinator: coordinator)
        .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
        .searchable(text: $searchText, prompt: "Search salon")
        .animation(.spring(duration: 1), value: searchText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(alignment: .center) {
                    Text("Choose Salon")
                        .foregroundColor(.yellow)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.push(page: .Master_upDateProfile)
                } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 28))
                }

            }
        })
        .foregroundStyle(Color.white)
        .tint(.yellow)
        .onDisappear {
            isLoader = false
        }

    }
    
    private func enterToSalon(company: Company_Model) async {
        
            isLoader = true
            let succes =  await Master_DataBase.shared.checkPassword_For(adminID: company.adminID)
            if succes {
                withAnimation {
                    
                    selectedAdmin = nil
                    MasterViewModel.shared.admin.adminID = company.adminID
                    MasterCalendarViewModel.shared.company.adminID = company.adminID
                    selectedAdminID = company.adminID
                    coordinator.push(page: .Master_Main)
                    isLoader = false
                }
            
            } else {
                isLoader = false
                withAnimation {
                
                    selectedAdmin = company.adminID
                    isTitle = "Not correct"
                    message = "The login was incorrect, perhaps the admin did not add you to the salon as a master"
                }
            }
      
    }
}
