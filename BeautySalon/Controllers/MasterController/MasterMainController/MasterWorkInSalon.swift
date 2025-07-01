//
//  MasterWorkInSalon.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 18/03/2025.
//

import SwiftUI

struct MasterWorkInSalon: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @ObservedObject var masterViewModel = MasterViewModel.shared
    @EnvironmentObject var storeKitView: StoreViewModel
    @EnvironmentObject var banner: InterstitialAdViewModel
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    
    
    @AppStorage("selectedAdmin") private var selectedAdminID: String?
    @State private var selectedAdmin: String? = nil
    @State private var loader: String = "Loading"
    @State private var message: String = ""
    @State private var isTitle: String = ""
    @State private var isLoader: Bool = false
    
    var body: some View {
        VStack {
                ScrollView {
                    VStack {
                        ForEach(masterViewModel.salonFavorites, id: \.self) { company in
                            
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
                                    CompanyAllCell(companyModel: company, isShow: selectedAdmin == company.id, isShowLike: false, isShowFavoritesSalon: true, isShowXmarkButton: true, onToggle: {})
                                }
                            .customAlert(isPresented: Binding(get: { selectedAdmin == company.adminID }, set: { newValue in
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
                        }
                    }
                }
                .createBackgrounfFon()
                .onAppear {
                    Task {
                        await masterViewModel.fetchFavoritesSalon()
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
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        TabBarButtonBack {
                            coordinator.pop()
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Working in a Salon")
                            .foregroundColor(.yellow)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                    }
                })
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

#Preview {
    MasterWorkInSalon()
}
