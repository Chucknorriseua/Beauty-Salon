//
//  AddNewMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import CoreLocation

struct AddNewMaster: View {

    @State private var searchText: String = ""
    @State private var isShowDetails: Bool = false
    @State private var selected: MasterModel? = nil
    @ObservedObject var adminModelView: AdminViewModel
    @StateObject private var locationManager = LocationManager()
    
    @Environment(\.dismiss) private var dismiss

    private var searchCompanyNearby: [MasterModel] {
        guard !searchText.isEmpty else { return []}
        guard let userLocation = locationManager.locationManager.location else {
            return  searchText.isEmpty ? adminModelView.allMasters :
            adminModelView.allMasters.filter({$0.name.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
        }
        
        let radius: CLLocationDistance = 10000
        return adminModelView.allMasters.filter { company in
            let matchesName = searchText.isEmpty ||  company.name.localizedCaseInsensitiveContains(searchText) || company.phone.localizedCaseInsensitiveContains(searchText)
            let isNearby: Bool
            if let distance = locationManager.calculateDistanceMaster(from: userLocation, to: company) {
                isNearby = distance <= radius
            } else {
                isNearby = false
            }
            return matchesName && isNearby
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(searchCompanyNearby, id: \.self) { master in
                            NavigationLink(destination: User_MasterDetailse(masterModel: master).navigationBarBackButtonHidden(true)) {
                                
                                AddNewMasterCell(addMasterInRoom: master)
                            }
                        }.padding(.bottom, 14)
                        
                    }
                    .padding(.top, 30)
            }.createBackgrounfFon()

        }.searchable(text: $searchText)
            .foregroundStyle(Color.white)
            .tint(Color.yellow)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if !isShowDetails {
                        TabBarButtonBack {
                            dismiss()
                        }} else {Text("")}
                }
            })
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Find a Master")
                        .foregroundStyle(isShowDetails ? Color.clear : Color.yellow.opacity(0.8))
                        .font(.system(size: 24, weight: .heavy).bold())
                }
            }
            .task({
                await adminModelView.fetchAllMastersFireBase()
            })
            .onDisappear {
                adminModelView.clearMemory()
            }
    }
}
