//
//  User_MyRecords.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 15/03/2025.
//

import SwiftUI

struct User_MyRecords: View {
    
    @ObservedObject var clientVM: ClientViewModel
    @Binding var deleteRecods: Shedule?
    
    var body: some View {
        VStack {
            Text("My Records")
                .foregroundStyle(Color.yellow)
                .font(.system(size: 24, weight: .bold))
                .fontDesign(.serif)
                .underline(color: .yellow)
        
                ScrollView {
                    LazyVStack {
                        ForEach(clientVM.myRecords, id: \.self) { records in
                            User_MyRecordsCell(myRecords: records, deleteRecords: $deleteRecods)
                            
                        }
                    }
                    .padding([.top, .bottom], 8)
                }
                .scrollIndicators(.hidden)
            .onAppear {
                Task {
                    await clientVM.fetchMyRecords()
                }
            }
        }
    }
}
