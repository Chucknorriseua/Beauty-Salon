//
//  UserSelectedComapnyController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI


struct UserSelectedComapnyController: View {
    
    @ObservedObject var clientViewModel: ClientViewModel
    @ObservedObject private var locationManager = LocationManager()
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeKitView: StoreViewModel
    @EnvironmentObject var banner: InterstitialAdViewModel
    
    @AppStorage("useRole") private var useRole: String?
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    
    @State private var selectedCategory: Categories = .nail
    @State private var selectedID: String? = nil
    @State private var isShowSubscription: Bool = false
    @State private var searchText: String = ""

    @State private var loader: String = "Loading"
    @State private var isLoader: Bool = false
    @State private var isShowMenu: Bool = false

    
    @State private var sliderDistance: Double = 500.0

    private var searchCompanyNearby: [Company_Model] {
        return SearchService.filterModels(
            models: clientViewModel.comapny,
            searchText: searchText,
            userLocation: locationManager.locationManager.location,
            radius: sliderDistance
        )
        .filter { $0.categories.localizedCaseInsensitiveContains(selectedCategory.rawValue) }
    }
    private var searchMasterHome: [MasterModel] {
        return SearchService.filterModels(
            models: clientViewModel.homeCall,
            searchText: searchText,
            userLocation: locationManager.locationManager.location,
            radius: sliderDistance
        )
//        .filter { $0.name.localizedCaseInsensitiveContains(selectedCategory.rawValue) }
    }
    
    var body: some View {
        VStack {
            
            VStack {
                ScrollView {
                    LazyVStack {
                        if selectedCategory == .housecall {
                            VStack {
                                ForEach(searchMasterHome, id:\.self) { master in
                                    NavigationLink(destination: AddNewMasterView(isShowButtonAdd: false,
                                                                                 isShowPricelist: true,
                                                                                 addMasterInRoom: master,
                                                                                 isShowMasterSend: true,
                                                                                 isShowSendButton: true).navigationBarBackButtonHidden(true)) {
                                        AddNewMasterCell(addMasterInRoom: master, isShowCategories: true)
                                    }.padding(.bottom, 12)
                                }
                            }.padding(.top, 30)
                        } else {
                            ForEach(searchCompanyNearby, id:\.self) { company  in
                                NavigationLink(destination: UserMainForSheduleController(clientViewModel:
                                                                                            clientViewModel).navigationBarBackButtonHidden(true)) {
                                    CompanyAllCell(companyModel: company, isShow: selectedID == company.id, isShowLike: true, onToggle: {
                                        withAnimation {
                                            if selectedID == company.id {
                                                selectedID = nil
                                            } else {
                                                selectedID = company.id
                                            }
                                        }

                                    })
                                        .onTapGesture {
                                            isLoader = true
                                            Task {
                                                clientViewModel.isFetchDataLoader = false
                                                clientViewModel.adminProfile.adminID = company.adminID
                                                await clientViewModel.fetchCurrent_AdminSalon(adminId: company.adminID)
                                                await MainActor.run {
                                                    if clientViewModel.isFetchDataLoader {
                                                        coordinator.push(page: .User_SheduleAdmin)
                                                    }
                                                    isLoader = false
                                                }
                                            }
                                        }
            
                                }.id(company)
                                    .disabled(isShowMenu)
           
                            }
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
                  
                }
                
                if searchCompanyNearby.isEmpty && clientViewModel.homeCall.isEmpty {
                    ContentUnavailableView("Salon not found...", systemImage: "house.lodge.circle.fill", description: Text("Please try again."))
                }
            }.scrollIndicators(.hidden)
                .overlay(alignment: .bottom) {
                    if !storeKitView.checkSubscribe {
                        Banner()
                            .frame(maxWidth: .infinity, maxHeight: 80)
                            .padding(.horizontal, 12)
                    }
                }
                .refreshable {
                    Task {
                        await clientViewModel.fetchAll_Comapny()
                    }
                }
                .scrollContentBackground(.hidden)
                .createBackgrounfFon()
                .customAlert(isPresented: $clientViewModel.isAlert, hideCancel: true, message: clientViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
        
                .overlay(alignment: .center) {CustomLoader(isLoader: $isLoader, text: $loader)}
                .overlay {
                    if isShowMenu {
                        Color.clear
                            .ignoresSafeArea()
                            .overlay(alignment: .center) {
                                ZStack {
                                    UserSelectedCategories(selectedCategory: $selectedCategory, distanceValue: $sliderDistance, onSelectedCategory: {
                                        withAnimation {
                                            isShowMenu.toggle()
                                        }
                                    })
                                }
                        }
                    }
                }

        }
        .overlay(alignment: .center, content: {
            if isShowSubscription {
                StoreKitBuyAdvertisement(isXmarkButton: $isShowSubscription)
            }
        })
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
                    Button(action: {
                        withAnimation(.easeIn) {
                            isShowMenu.toggle()
                        }
                    }) {
                        Image(systemName: "filemenu.and.selection")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.white)
                    }
                }
            })
            .foregroundStyle(Color.white)
            .tint(.yellow)
            .task({
                await clientViewModel.fetchAll_Comapny()
            })
            .onAppear {
                locationManager.isUpdateLocation = true
                locationManager.startUpdate()

            }
            .onDisappear {
                isShowMenu = false
                locationManager.isUpdateLocation = false
                locationManager.stopUpdate()
            }
    }
    
}
