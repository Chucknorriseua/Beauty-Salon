//
//  AdminCreatePriceList.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 12/01/2025.
//

import SwiftUI

struct AdminCreatePriceList: View {
    
   
    @Environment (\.dismiss) var dismiss
    @ObservedObject var adminViewModel: AdminViewModel
    @State private var isShowSheet: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(adminViewModel.createProcedure, id:\.self) { proced in
                        ProcedureCell(procedure: proced, adminViewModel: adminViewModel)
                    }
                }.padding(.top, 10)
                    .animation(.easeInOut(duration: 1), value: adminViewModel.createProcedure)
            }
        }.createBackgrounfFon()
            .onDisappear {
                Task { await adminViewModel.refreshProfileAdmin()}
            }
            .sheet(isPresented: $isShowSheet, content: {
                AdminSheetCreatPriceList(adminViewModel: adminViewModel)
                    .presentationDetents([.height(380)])
//                    .interactiveDismissDisabled()
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        dismiss()
                    }
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
