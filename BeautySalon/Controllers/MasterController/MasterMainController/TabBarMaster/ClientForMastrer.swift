//
//  ClientForMastrer.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 02/09/2024.
//

import SwiftUI

struct ClientForMastrer: View {
    
    
    @ObservedObject var masterViewModel: MasterViewModel
    @ObservedObject var VmCalendar: MasterCalendarViewModel
    
// MARK: Fetch all User Of Company
    var body: some View {
        NavigationView(content: {
                
                VStack {
                    Text("Clients for recording")
                        .font(.system(.title, design: .serif, weight: .regular))
                        .foregroundStyle(Color.yellow)
                    
                    ScrollView {
                        LazyVStack(alignment: .center) {
                            
                            ForEach(VmCalendar.client, id:\.self) { user in
                                CellUser(clientModel: user)
                            }
                            
                        }.padding(.top, 10)
                        
                    }.scrollIndicators(.hidden)
                        .refreshable {
                            Task {
                                await VmCalendar.fetchCurrentClient()
                            }
                        }
                }
                .createBackgrounfFon()
           
        })
    }
}
