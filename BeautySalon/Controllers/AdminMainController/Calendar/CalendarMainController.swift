//
//  HeaderCalendarView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI

struct CalendarMainController: View {
    
    @StateObject var viewModel = Admin_CalendarViewModel()
    @StateObject var adminViewModel: AdminViewModel
    @State var masterModel: MasterModel
    
    var body: some View {
        GeometryReader { geo in
            
            VStack {
                HeaderView(viewModel: viewModel, adminViewModel: adminViewModel, masterModel: masterModel)
                ScrollView {
                    TasksForSelectedDate(viewModel: viewModel, masterModel: masterModel, currentDate: viewModel.currentDate)
                }
                .scrollIndicators(.hidden)
            
            }
            .onAppear {
                viewModel.setupWeeks()
                Task { await viewModel.fetchAllSheduleCurrentMaster(masterID: masterModel.masterID, sheduleMaster: viewModel.shedules)
                }
            }
        }
    }
}
