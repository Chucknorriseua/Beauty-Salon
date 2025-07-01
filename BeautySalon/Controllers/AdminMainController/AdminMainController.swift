//
//  AdminAllMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct AdminMainController: View {
    
    @ObservedObject var admimViewModel: AdminViewModel
    
    @EnvironmentObject var storeKitView: StoreViewModel
    @StateObject var banner = InterstitialAdViewModel()
 
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    
    @State private var selecetedRecord: Shedule? = nil
    @State private var isShowListMaster: Bool = false
    @State private var isShowRedactor: Bool = false
    @State private var isShowDelete: Bool = false
    @State private var isRefreshID: Bool = false
    @State private var isShowSubscription: Bool = false
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
                                }
                            }
                        }
                        .padding(.top, 18)
                        .padding(.bottom, 60)
                        
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
             
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            if !firstSignIn {
                                withAnimation(.easeOut(duration: 1)) {
                                    if !storeKitView.checkSubscribe {
                                        isShowSubscription = true
                                    }
                                }
                                if !storeKitView.checkSubscribe {
                                 
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        if let rootVC = UIApplication.shared.connectedScenes
                                            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                                            .first {
                                            banner.showAd(from: rootVC)
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            .createBackgrounfFon()
                .overlay(alignment: .center, content: {
                    if isShowSubscription {
                        StoreKitBuyAdvertisement(isXmarkButton: $isShowSubscription)
                    }
                })
            
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
                        NavigationLink(destination: AddNewMaster(adminModelView: admimViewModel).navigationBarBackButtonHidden(true)) {
                            
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .font(.system(size: 28))
                            .foregroundStyle(Color.white)
                        }
                    }
                })
                .foregroundStyle(Color.white)
          
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: AdminMyMastersController(adminViewModel: admimViewModel)) {
                            
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.white)
                        }.navigationBarBackButtonHidden(true)
                        
                    }
                })
              
                .foregroundStyle(Color.white)
                .tint(.yellow)
                .sheet(isPresented: $isShowListMaster, content: {
                    AdminListMasterAddShedule(adminViewModel: admimViewModel, selecetedRecord: $selecetedRecord)
                        .presentationDetents([.height(500)])
                        
                })
                .sheet(isPresented: $isShowRedactor, content: {
                    
                    AdminSheetRedactorShedule(adminViewModel: admimViewModel, selecetedRecord: $selecetedRecord)
                        .presentationDetents([.height(580)])
                    
                })
        }
        
    }
}

