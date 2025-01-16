//
//  UserSelectedComapnyController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI
import CoreLocation

struct UserSelectedComapnyController: View {
    
    @StateObject var clientViewModel: ClientViewModel
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var google: GoogleSignInViewModel
    @Environment (\.dismiss) var dismiss
    
    @AppStorage ("useRole") private var useRole: String?
    @State private var selectedCategory: Categories = .nail
    @State private var selectedID: String? = nil
    
    @State private var searchText: String = ""
    @State private var loader: String = "Loader"
    @State private var isLoader: Bool = false
    @State private var isShowMenu: Bool = false
    
    @State private var sliderDistance: Double = 500.0
    
    
    private var searchCompanyNearby: [Company_Model] {
        guard let userLocation = locationManager.locationManager.location else {
            return filterCompanies(clientViewModel.comapny)
        }

        let radius: CLLocationDistance = sliderDistance
        let nearbyCompanies = clientViewModel.comapny.filter { company in
            if let distance = locationManager.calculateDistance(from: userLocation, to: company) {
                return distance <= radius
            }
            return false
        }
        return filterCompanies(nearbyCompanies)
    }

    private func filterCompanies(_ companies: [Company_Model]) -> [Company_Model] {
        companies.filter { company in
            let matchesName = searchText.isEmpty || company.companyName.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = company.categories.localizedCaseInsensitiveContains(selectedCategory.rawValue)
            return matchesName && matchesCategory
        }
    }
    
    var body: some View {
        VStack {
            
            VStack {
                ScrollView {
                    LazyVStack {
                        
                        ForEach(searchCompanyNearby, id:\.self) { company  in
                            NavigationLink(destination: UserMainForSheduleController(clientViewModel:
                                                                                        clientViewModel).navigationBarBackButtonHidden(true)) {   
                                CompanyAllCell(companyModel: company, isShow: selectedID == company.id, onToggle: {
                                    withAnimation {
                                        if selectedID == company.id {
                                            selectedID = nil
                                        } else {
                                            selectedID = company.id
                                        }
                                    }

                                })
                                .padding(.bottom, 30)
                                    .onTapGesture {
                                        isLoader = true
                                        Task {
                                            clientViewModel.adminProfile.adminID = company.adminID
                                            await clientViewModel.fetchCurrent_AdminSalon(adminId: company.adminID)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                
                                                coordinator.push(page: .User_SheduleAdmin)
                                                isLoader = false
                                            }
                                        }
                                    }
        
                            }.id(company)
                                .disabled(isShowMenu)
                                .scrollTransition(.animated) { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .offset(y: phase.isIdentity ? 0 : 40)
                                    
                                }
                            
                        }
                    }.scrollTargetLayout()
                
                }
            }.scrollIndicators(.hidden)
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

        }.searchable(text: $searchText)
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
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        Task {
                            useRole = nil
                            try await google.logOut()
                            Auth_ClientViewModel.shared.signOutClient()
                            coordinator.popToRoot()
                        }
                    }
                }
            })
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
            .onAppear {
                locationManager.isUpdateLocation = true
                locationManager.startUpdate()
                Task {
                await clientViewModel.fetchAll_Comapny()
                }
            }
            .onDisappear {
                locationManager.isUpdateLocation = false
                locationManager.stopUpdate()
            }
    }
    
}

#Preview {
    UserSelectedComapnyController(clientViewModel: ClientViewModel.shared)
}
