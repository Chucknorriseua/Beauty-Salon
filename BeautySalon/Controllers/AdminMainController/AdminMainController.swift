//
//  AdminAllMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct AdminMainController: View {
    
    @StateObject var admimViewModel: AdminViewModel
    
    @State private var selecetedRecord: Shedule? = nil
    @State private var isShowListMaster: Bool = false
    @State private var isShowRedactor: Bool = false
    @State private var isShowDelete: Bool = false
    @State private var isRefreshID: Bool = false
    @State private var refreshID = UUID()
    @State private var message: String = "Do you want to delete the record?"
    
    var body: some View {
        NavigationView {
            
            VStack {
                VStack {
                    ScrollView {
                        LazyVStack {
                            ForEach(admimViewModel.recordsClient, id: \.id) { record in
                                VStack {
                                    
                                    AdminSheduleFromClientCell(recordModel: record, viewModelAdmin: admimViewModel,
                                                               isShowAlert: $isShowDelete, isShowList: $isShowListMaster, isShowRedactorDate: $isShowRedactor, selecetedRecord: $selecetedRecord).onTapGesture(perform: {
                                        selecetedRecord = record
                                    })
                                       .transition(.opacity)
                                       .scrollTransition(.animated) { content, phase in
                                           content
                                               .opacity(phase.isIdentity ? 1 : 0)
                                               .offset(y: phase.isIdentity ? 0 : -40)
                                       }
                                }
                            }
                        }
                        .padding(.top, 18)
                        .padding(.bottom, 60)
                        .onAppear {
                            Task {
                                await admimViewModel.fetchClientRecords()
                            }
                        }
                        
                    }.scrollIndicators(.hidden)
                        .id(refreshID)
                        .refreshable {
                            withAnimation(.snappy(duration: 0.5)) {
                                isRefreshID = true
                            }
                            Task {
                                await admimViewModel.fetchClientRecords()
                                withAnimation(.snappy(duration: 0.5)) {
                                    refreshID = UUID()
                                    isRefreshID = false
                                }
                            }
                        }
                    
                }.disabled(isShowDelete)
            }.createBackgrounfFon()
                .overlay(alignment: .center, content: {
                    ZStack {}
                        .customAlert(isPresented: $isShowDelete, hideCancel: true, message: message, title: "") {
                            Task {
                                if let record = selecetedRecord {
                                    await admimViewModel.deleteRecord(record: record)
                                }
                            }
                        } onCancel: {}
                })
            
                .customAlert(isPresented: $admimViewModel.isAlert, hideCancel: true, message: admimViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: AddNewMaster(adminModelView: admimViewModel)) {
                            
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .font(.system(size: 28))
                            .foregroundStyle(Color.white) }.navigationBarBackButtonHidden(true)
                    }
                })
                .foregroundStyle(Color.white)
                .tint(.yellow)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: AdminListMasterDelete(adminViewModel: admimViewModel)) {
                            
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.system(size: 28))
                            .foregroundStyle(Color.white)}.navigationBarBackButtonHidden(true)
                        
                    }
                })
                .foregroundStyle(Color.white)
                .tint(.yellow)
                .sheet(isPresented: $isShowListMaster, content: {
                    AdminListMasterAddShedule(adminViewModel: admimViewModel, selecetedRecord: $selecetedRecord)
                        .presentationDetents([.height(500)])
                        .interactiveDismissDisabled()
                })
                .sheet(isPresented: $isShowRedactor, content: {
                    
                    AdminSheetRedactorShedule(adminViewModel: admimViewModel, selecetedRecord: $selecetedRecord)
                        .presentationDetents([.height(540)])
                    
                })
        }
        
    }
}

