//
//  ClientView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct GetAllMastersInCompany: View {
    
    @ObservedObject var adminViewModel: AdminViewModel

    
    var body: some View {
        NavigationView {
                VStack {
                    Text("Send schedule for master")
                        .font(.system(.title, design: .serif, weight: .regular))
                        .foregroundStyle(Color.yellow)
                    ScrollView {
                        
                        LazyVStack {
                            //  MARK: Shedul For Master Calendar
                            ForEach(adminViewModel.addMasterInRoom, id: \.id) { item in
                                NavigationLink(destination: AdminAddForMasterShedule(adminViewModel: adminViewModel,
                                                                                     masterModel: item).navigationBarBackButtonHidden(true)) {
                                    CellMaster(masterModel: item)

                                }
                            }
                            
                        }.padding(.top, 40)
                    }.scrollIndicators(.hidden)
                        
                    
                }
                .createBackgrounfFon()
            
        }
    }
}
