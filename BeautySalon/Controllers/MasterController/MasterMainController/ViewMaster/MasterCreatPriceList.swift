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
    @EnvironmentObject var storeKitView: StoreViewModel
    
    @State private var isShowSheet: Bool = false
    @State private var masterOffsets: [String: CGFloat] = [:]
    @State private var selectedMaster: String? = nil
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(masterVM.createProcedure, id:\.self) { proced in
                        MasterProcedureCell(procedure: proced, masterVM: masterVM)
                            .offset(x: masterOffsets[proced.id] ?? 0)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.width < 0 {
                                            if selectedMaster != proced.id {
                                                removeOffset()
                                                selectedMaster = proced.id
                                            }
                                            masterOffsets[proced.id] = value.translation.width
                                        }
                                    }
                                    .onEnded { value in
                                    
                                        if value.translation.width < -100 {
                                            masterOffsets[proced.id] = -100
                           
                                        } else {
                                            masterOffsets[proced.id] = 0
                                  
                                            selectedMaster = nil
                                        }
                                    }
                            )
                            .animation(.spring(), value: masterOffsets[proced.id])
                    }
                }.padding(.top, 10)
                    .animation(.easeInOut(duration: 1), value: masterVM.createProcedure)
            }
        }
        .overlay(alignment: .bottom) {
            if !storeKitView.checkSubscribe {
                Banner()
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .padding(.horizontal, 12)
            }
        }
        .createBackgrounfFon()

            .sheet(isPresented: $isShowSheet, content: {
                MasterSheetAddProcedure(masterVM: masterVM)
                    .presentationDetents([.height(380)])
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
    private func removeOffset() {
        for key in masterOffsets.keys {
            masterOffsets[key] = 0
        }
    }
}
