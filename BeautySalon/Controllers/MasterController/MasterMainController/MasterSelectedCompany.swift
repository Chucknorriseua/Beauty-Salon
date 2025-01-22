//
//  MasterSelectedCompany.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 22/08/2024.
//

import SwiftUI
import CoreLocation

struct MasterSelectedCompany: View {
    
    @StateObject var masterViewModel: MasterViewModel
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
    @State private var selectedID: String? = nil
    
    
    
    private var searchCompanyNearby: [Company_Model] {
        guard let userLocation = locationManager.locationManager.location else {
            return  searchText.isEmpty ? masterViewModel.company :
            masterViewModel.company.filter({$0.companyName.localizedCaseInsensitiveContains(searchText)})
        }
        
        let radius: CLLocationDistance = 10000
        return masterViewModel.company.filter { company in
            let matchesName = searchText.isEmpty ||  company.companyName.localizedCaseInsensitiveContains(searchText)
            let isNearby: Bool
            if let distance = locationManager.calculateDistance(from: userLocation, to: company) {
                isNearby = distance <= radius
            } else {
                isNearby = false
            }
            return matchesName && isNearby
        }
    }
    
    var body: some View {
        
        VStack {
            ScrollView {
                LazyVStack {
                    
                    ForEach(searchCompanyNearby, id:\.self) { company in
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
                            CompanyAllCell(companyModel: company, isShow: selectedID == company.id, onToggle: {})
                        }
                        .customAlert(isPresented: Binding(get: { selectedAdmin == company.adminID }, set: { newValue in
                            if !newValue { selectedAdmin = nil }
                        }), hideCancel: true, message: message, title: isTitle) {
                            
                            Task { await enterToSalon(company: company)}
                            
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
                ContentUnavailableView("Masters not found...", systemImage: "house.lodge.circle.fill", description: Text("Please try again."))
            }
        })
        .searchable(text: $searchText, prompt: "Search salon")
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
                    MasterCalendarViewModel.shared.company.adminID = company.adminID
                    masterViewModel.admin.adminID = company.adminID
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
