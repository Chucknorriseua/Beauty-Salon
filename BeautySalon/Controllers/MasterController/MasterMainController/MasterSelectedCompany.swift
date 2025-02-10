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

    @AppStorage ("selectedAdmin") private var selectedAdminID: String?
    @AppStorage ("useRole") private var useRole: String = ""
    
    @State private var selectedAdmin: String? = nil
    @State private var searchText: String = ""
    @State private var loader: String = "Loading"
    @State private var message: String = ""
    @State private var isTitle: String = ""
    @State private var isLoader: Bool = false
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
                                CompanyAllCell(companyModel: company, isShow: selectedAdmin == company.id, onToggle: {})
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
                            .padding(.bottom, 26)
                    
                            .scrollTransition(.animated) { content, phase in
                                    
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .offset(y: phase.isIdentity ? 0 : 40)
                            }
                    }
                }.scrollTargetLayout()
                
            }.scrollIndicators(.hidden)
            
    
        }
        .createBackgrounfFon()
        .customAlert(isPresented: $masterViewModel.isAlert, hideCancel: true, message: masterViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
        .swipeBack(coordinator: coordinator)
        .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
        .overlay(content: {
            if searchCompanyNearby.isEmpty {
                ContentUnavailableView("Salon not found...", systemImage: "house.lodge.circle.fill", description: Text("Please try again."))
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
            ToolbarItem(placement: .topBarLeading) {
                TabBarButtonBack {
                    signOut()
                }
            }
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
    private func signOut() {
        Task {
            selectedAdminID = nil
            useRole = ""
            Auth_Master_ViewModel.shared.signOut()
            try await GoogleSignInViewModel.shared.logOut()
            coordinator.popToRoot()
        }
    }
}
