//
//  ClientForMastrer.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 02/09/2024.
//

import SwiftUI

struct ClientForMastrer: View {
    
    
 @StateObject var masterViewModel: MasterViewModel
    
// MARK: Fetch all User Of Company
    var body: some View {
        NavigationView(content: {
                
                VStack {
                    Text("Clients for recording")
                        .font(.system(.title, design: .serif, weight: .regular))
                        .foregroundStyle(Color.yellow)
                    
                    ScrollView {
                        LazyVStack(alignment: .center) {
                            
                            ForEach(masterViewModel.client, id:\.self) { user in
                                CellUser(clientModel: user)
                            }
                            
                        }.padding(.top, 30)
                        
                    }.scrollIndicators(.hidden)
                    
                }
                .createBackgrounfFon()
           
        }).onAppear {
            Task { await masterViewModel.fetchCurrentClient() }
        }
    }
}
