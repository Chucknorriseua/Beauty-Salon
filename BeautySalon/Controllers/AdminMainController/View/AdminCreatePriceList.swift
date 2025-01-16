//
//  AdminCreatePriceList.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 12/01/2025.
//

import SwiftUI

struct AdminCreatePriceList: View {
    
   
    @EnvironmentObject var coordinator: CoordinatorView
    @StateObject var adminViewModel: AdminViewModel
    @State private var isShowSheet: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(adminViewModel.adminProfile.procedure, id:\.self) { proced in
                        ProcedureCell(procedure: proced, adminViewModel: adminViewModel)
                    }
                }.padding(.top, 10)
            }
        }.createBackgrounfFon()
            .sheet(isPresented: $isShowSheet, content: {
                AdminSheetCreatPriceList(adminViewModel: adminViewModel)
                    .presentationDetents([.height(380)])
//                    .interactiveDismissDisabled()
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        coordinator.pop()
                    }
                }
                ToolbarItem(placement: .principal) {
                  Text("Price list")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.yellow.opacity(0.9))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowSheet = true
                    }, label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.yellow.opacity(0.9))
                    })
                }
            })
    }
}

#Preview {
    AdminCreatePriceList(adminViewModel: AdminViewModel.shared)
}
