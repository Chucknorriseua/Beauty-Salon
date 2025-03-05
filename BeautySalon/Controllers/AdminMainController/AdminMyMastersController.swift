//
//  AdminMyMastersController.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 10/02/2025.
//

import SwiftUI

struct AdminMyMastersController: View {
    
    
    @ObservedObject var adminViewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var masterOffsets: [String: CGFloat] = [:]
    @State private var selectedMaster: String? = nil

    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(adminViewModel.addMasterInRoom, id: \.self) { master in
                        NavigationLink(destination: AddNewMasterView(isShowButtonAdd: false, isShowPricelist: false, addMasterInRoom: master, isShowMasterSend: false).navigationBarBackButtonHidden(true)) {
                            
                            CellListMasterDelete(master: master, adminViewModel: adminViewModel)
                     
                                .offset(x: masterOffsets[master.id] ?? 0)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if value.translation.width < 0 {
                                                if selectedMaster != master.id {
                                                    removeOffset()
                                                    selectedMaster = master.id
                                                }
                                                masterOffsets[master.id] = value.translation.width
                                            }
                                        }
                                        .onEnded { value in
                                        
                                            if value.translation.width < -100 {
                                                masterOffsets[master.id] = -100
                               
                                            } else {
                                                masterOffsets[master.id] = 0
                                      
                                                selectedMaster = nil
                                            }
                                        }
                                )
                                .animation(.spring, value: masterOffsets[master.id])
                        }
                    }
                }.padding(.vertical, 6)
            }
        }
        .createBackgrounfFon()
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    TabBarButtonBack {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text("My master")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.yellow.opacity(0.9))
                  
            }
        }).navigationBarBackButtonHidden(true)
    }

    private func removeOffset() {
        for key in masterOffsets.keys {
            masterOffsets[key] = 0
        }
    }
}
