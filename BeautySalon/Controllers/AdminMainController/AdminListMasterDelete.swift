//
//  AdminListMasterDelete.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI

struct AdminListMasterDelete: View {
    
    
    @ObservedObject var adminViewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        VStack {
            List {
                Section {
                    ForEach(adminViewModel.addMasterInRoom, id: \.self) { master in
                        NavigationLink(destination: AddNewMasterView(isShowButtonAdd: false, addMasterInRoom: master).navigationBarBackButtonHidden(true)) {
                            CellListMasterDelete(master: master)
                            
                        }.listRowBackground(Color.init(hex: "#3e5b47").opacity(0.5))
                    }.onDelete(perform: { indexSet in
                        deleteMaster(indexOffset: indexSet)
                    })
                    
                }
            }.listStyle(.plain)
                .padding(.top, 10)
                .background(Color.init(hex: "#3e5b47").opacity(0.9))
               
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    TabBarButtonBack {
                        dismiss()
                    }
                    Text("Remove master")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.yellow.opacity(0.9))
                        .padding()
                }
            }
        }).navigationBarBackButtonHidden(true)
    }
    func deleteMaster(indexOffset: IndexSet) {
        Task {
            for index in indexOffset {
                let masterIndex = adminViewModel.addMasterInRoom[index]
                await adminViewModel.deleteMasterFromSalon(master: masterIndex)
                
            }
        }
    }
}
