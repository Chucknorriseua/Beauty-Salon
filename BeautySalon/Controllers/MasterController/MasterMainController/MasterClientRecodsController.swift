//
//  MasterClientRecodsController.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 21/02/2025.
//

import SwiftUI

struct MasterClientRecodsController: View {
    
    @ObservedObject var masterVM = MasterViewModel.shared
    @EnvironmentObject var coordinator: CoordinatorView
    @EnvironmentObject var storeKitView: StoreViewModel
    
    @State private var isShowSheet: Bool = false
    @State private var selecetedRecord: Shedule? = nil
    @State private var isShowDelete: Bool = false
    @State private var isAddSheduleStatic: Bool = false
    @State private var message: String = "Do you want to delete the record?"
    @State private var messageStatic: String = "Add an entry to monthly statistics to track monthly data."
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(masterVM.sheduleFromClient, id: \.self) { shedule in
                        RecordsFromClientCell(shedule: shedule, isShowChange: $isShowSheet, selecetedRecord: $selecetedRecord, isShowDelete: $isShowDelete, isAddSheduleStatic: $isAddSheduleStatic)
                    }
                }
                .padding(.bottom, 8)
                Spacer()
            }
            .refreshable {
                Task {
                    await masterVM.fetchSheduleFromClient()
                }
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                if !storeKitView.checkSubscribe {
                    VStack {
                        Banner()
                            .frame(maxWidth: .infinity, maxHeight: 80)
                            .padding(.horizontal, 12)
                    }
                    .padding(.bottom, 10)
                }
            }
            .createBackgrounfFon()
            .customAlert(isPresented: $isShowDelete, hideCancel: true, message: message, title: "") {
                delete()
            } onCancel: {}
                .customAlertWithImage(isPresented: $isAddSheduleStatic, hideCancel: true, message: messageStatic, title: "", isShowImage: true, imageName: "monitor") {
                    Task {
                        guard let shedule = selecetedRecord else { return }
                        await masterVM.addSheduleInMyStatic(sheduleID: shedule)
                        delete()
                    }
            } onCancel: {}
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                TabBarButtonBack {
                    coordinator.pop()
                }
            }
        })
        .sheet(isPresented: $isShowSheet, content: {
            
            MasterSheetRedactorRecords(masterVM: masterVM, selecetedRecord: $selecetedRecord)
                .presentationDetents([.height(260)])
        })
    }
    
    private func delete() {
        guard let shedule = selecetedRecord else { return }
        Task {
            await masterVM.deleteShedule(sheduleID: shedule)
        }
    }
}

#Preview {
    MasterClientRecodsController(masterVM: MasterViewModel.shared)
}
