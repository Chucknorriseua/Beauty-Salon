//
//  MasterCreatPriceList.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/01/2025.
//

import SwiftUI

struct MasterCreatPriceList: View {
    
   
    @EnvironmentObject var coordinator: CoordinatorView
    @ObservedObject var masterVM = MasterViewModel.shared
    @State private var isShowSheet: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(masterVM.createProcedure, id:\.self) { proced in
                        MasterProcedureCell(procedure: proced, masterVM: masterVM)
                    }
                }.padding(.top, 10)
                    .animation(.easeInOut(duration: 1), value: masterVM.createProcedure)
            }
        }.createBackgrounfFon()
            .onDisappear {
//                Task { await masterVM.refreshProfileAdmin()}
            }
            .sheet(isPresented: $isShowSheet, content: {
                MasterSheetAddProcedure(masterVM: masterVM)
                    .presentationDetents([.height(380)])
//                    .interactiveDismissDisabled()
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        coordinator.pop()
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
