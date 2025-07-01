//
//  HeaderCalendarView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI

struct CalendarMainController: View {
    
    @ObservedObject var viewModel: Admin_CalendarViewModel
    @ObservedObject var adminViewModel: AdminViewModel
    @State var masterModel: MasterModel
    @EnvironmentObject var storeKitView: StoreViewModel
    
    var body: some View {
        GeometryReader { geo in
            
            VStack {
                HeaderView(viewModel: viewModel, adminViewModel: adminViewModel, masterModel: masterModel)
                ScrollView {
                    TasksForSelectedDate(viewModel: viewModel, masterModel: masterModel, currentDate: viewModel.currentDate)
                }
                .scrollIndicators(.hidden)
            
            }
            .overlay(alignment: .bottom) {
                if !storeKitView.checkSubscribe {
                    VStack {
                        Banner()
                            .frame(maxWidth: .infinity, maxHeight: 80)
                            .padding(.horizontal, 12)
                    }
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                viewModel.setupWeeks()
                Task { await viewModel.fetchAllSheduleCurrentMaster(masterID: masterModel.masterID, sheduleMaster: viewModel.shedules)
                }
            }
        }
    }
}
