//
//  AdminAllMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct AdminMainController: View {
    
    @StateObject var admimViewModel: AdminViewModel

    @State private var scrollId: String? = nil
    @State private var selecetedRecord: Shedule? = nil
    @State private var isLoading: Bool = false
    @State private var isShowListMaster: Bool = false
    
    
    var body: some View {
        
        NavigationView(content: {
            VStack {
                ScrollView {
                    
                    LazyVStack {
                        ForEach(admimViewModel.recordsClient, id: \.id) { record in
                            VStack {
                                
                                RecordFlippedCell(recordModel: record, viewModelAdmin: admimViewModel,
                                                  isShowList: $isShowListMaster, selecetedRecord: $selecetedRecord).onTapGesture {
                                    selecetedRecord = record
                                }.id(record.id)
                                
                                    .scrollTransition(.interactive) { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .offset(y: phase.isIdentity ? 0 : -40)
                                    }
                            }.padding(.bottom, -40)
                        }
                    }.padding(.top, 18)
                        .animation(.easeOut(duration: 0.5), value: admimViewModel.recordsClient)
                    .padding(.bottom, 60)
                    .onAppear {
                        Task {
                            isLoading = true
                            await admimViewModel.getPagination_DataRecord(isLoading: true)
                            isLoading = false
                        }
                    }
                    
                    
                }.scrollIndicators(.hidden)
                    .scrollPosition(id: $scrollId, anchor: .bottom)
                    .onChange(of: scrollId) { _, new in
                        if (new != nil) && !isLoading {
                            
                            Task {
                                isLoading = true
                                await admimViewModel.getPagination_DataRecord(isLoading: false)
                                isLoading = false
                            }
                        }
                    }
                
            }.scrollTargetLayout()
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
                        NavigationLink(destination: AdminListNews(adminViewModel: admimViewModel)) {
                            
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.system(size: 28))
                            .foregroundStyle(Color.white)}.navigationBarBackButtonHidden(true)
                        
                    }
                })
                .foregroundStyle(Color.white)
                .tint(.yellow)
                .createBackgrounfFon()
                .sheet(isPresented: $isShowListMaster, content: {
                    AdminListMasterAddShedule(adminViewModel: admimViewModel, selecetedRecord: $selecetedRecord)
                        .presentationDetents([.height(500)])
                        .interactiveDismissDisabled()
                })
        })
        .refreshable {
            Task {
                await admimViewModel.getPagination_DataRecord(isLoading: true)
            }
        }
    }
}
