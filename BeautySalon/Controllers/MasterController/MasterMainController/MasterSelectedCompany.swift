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
    @AppStorage ("shoudNavManin") private var shoudNavManin: Bool = false
    
    @State private var selectedAdmin: String? = nil
    @State private var searchText: String = ""
    @State private var loader: String = "Loader"
    @State private var isMessageNT: String = ""
    @State private var isTitle: String = ""
    @State private var isLoader: Bool = false
  
    
    
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
                                isTitle = "Do you want to enter \(company.companyName) salon?".uppercased()
                            }
                        } label: {
                            CompanyAllCell(companyModel: company)
                        }.customAlert(isPresented: Binding(get: { selectedAdmin == company.adminID }, set: { newValue in
                            if !newValue { selectedAdmin = nil }
                        }), message: isMessageNT, title: isTitle) {
                            
                            Task { await enterToSalon(company: company)}
                            
                        } onCancel: {
                            selectedAdmin = nil
                            isTitle = ""
                            isMessageNT = ""
                        }.id(company)
                            .padding(.bottom, 46)
                    
                            .scrollTransition(.animated) { content, phase in
                                withAnimation(.snappy(duration: 1)) {
                                    
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .offset(y: phase.isIdentity ? 0 : 80)
                                }
                            }
                    }
                }.scrollTargetLayout()
                
            }.scrollIndicators(.hidden)
    
        }
        .createBackgrounfFon()
        .swipeBack(coordinator: coordinator)
        .overlay(alignment: .center) { CustomLoader(isLoader: $isLoader, text: $loader) }
        .searchable(text: $searchText)
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
                    coordinator.popToRoot()
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
        .onAppear {
            Task {
            await checkStateLogin()
            }

        }.navigationDestination(isPresented: $shoudNavManin) {
            MasterTabBar(masterViewModel: masterViewModel, VmCalendar: MasterCalendarViewModel.shared).navigationBarBackButtonHidden(true)
        }.onDisappear {
            isLoader = false
        }

    }
    
    private func checkStateLogin() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let saveAdmin = selectedAdminID {
                isLoader = true
                MasterCalendarViewModel.shared.company.adminID = saveAdmin
                masterViewModel.admin.adminID = saveAdmin
                shoudNavManin = true
            } else {
                isLoader = false
                print("no selected")
            }
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
                    isMessageNT = "The login was incorrect, perhaps the admin did not add you to the salon as a master"
                }
            }
      
    }
}
