//
//  Informations.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct GetAllUsersOfCompany: View {
    
    @ObservedObject var adminViewModel: AdminViewModel
    
    // MARK: Fetch all User Of Company
    var body: some View {
        NavigationView {
            
            VStack {
                Text("Clients for recording")
                    .font(.system(.title, design: .serif, weight: .regular))
                    .foregroundStyle(Color.yellow)
                
                ScrollView {
                    LazyVStack(alignment: .center) {
                        
                        ForEach(adminViewModel.client, id:\.self) { user in
                            CellUser(clientModel: user)
                            
                        }
                        
                    }.padding(.top, 30)
                        .padding(.bottom, 50)
                    
                }.scrollIndicators(.hidden)
                
            }
            .createBackgrounfFon()
            .refreshable {
                Task {
                    await adminViewModel.fetchCurrentClient()
                }
            }
        }
        
    }
}
