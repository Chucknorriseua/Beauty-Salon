//
//  AddNewMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI


struct AddNewMaster: View {

    @State private var searchText: String = ""
    @State private var isShowDetails: Bool = false
    @State private var distance: Double = 10000

    @ObservedObject var adminModelView: AdminViewModel
    @StateObject private var locationManager = LocationManager()
    
    @Environment(\.dismiss) private var dismiss
   
    private var searchCompanyNearby: [MasterModel] {
    SearchService.filterModels(models: adminModelView.allMasters,
                               searchText: searchText,
                               userLocation: locationManager.locationManager.location,
                               radius: distance)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(searchCompanyNearby, id: \.id) { master in
                            NavigationLink(destination: AddNewMasterView(isShowButtonAdd: true, isShowPricelist: false, addMasterInRoom: master).navigationBarBackButtonHidden(true)) {
                                
                                AddNewMasterCell(addMasterInRoom: master)
                            }
                        }
                    }
                    .padding(.top, 40)
                }
                .refreshable {
                    Task { await adminModelView.fetchAllMastersFireBase() }
                }
            }
            .createBackgrounfFon()
            .searchable(text: $searchText, prompt: "Search masters")
            .animation(.spring(duration: 1), value: searchText)
                .overlay(content: {
                    if searchCompanyNearby.isEmpty {
                        ContentUnavailableView("Nail master not found...", systemImage: "person.2.slash.fill", description: Text("Please try again."))
                    }
                })
            .foregroundStyle(Color.white)
            .tint(Color.yellow)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if !isShowDetails {
                        TabBarButtonBack {
                            dismiss()
                        }} else {Text("")}
                }
                ToolbarItem(placement: .navigation) {
                    Text("Find a Master")
                        .foregroundStyle(isShowDetails ? Color.clear : Color.yellow.opacity(0.8))
                        .font(.system(size: 24, weight: .heavy).bold())
                }
            })
            .onAppear {
                Task {
                    await adminModelView.fetchAllMastersFireBase()
                }
            }
          
        }
    }
}
