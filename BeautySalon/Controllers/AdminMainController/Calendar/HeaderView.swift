//
//  CellCalendar.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI

struct HeaderView: View {
    
    @ObservedObject var viewModel: Admin_CalendarViewModel
    @StateObject var adminViewModel: AdminViewModel
    @Environment(\.dismiss) var dismiss
    @State var masterModel: MasterModel
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(viewModel.currentDate.format("MMMM"))
                    Text(viewModel.currentDate.format("YYYY"))
                }
                .foregroundStyle(Color.yellow)
                .font(.title.bold())
                
                Text(viewModel.currentDate.formatted(date: .complete, time: .omitted))
                    .foregroundStyle(Color.white)
                    .font(.callout)
                
                TabView(selection: $viewModel.currentWeekIndex) {
                    ForEach(viewModel.weekSlider.indices, id:\.self) { index in
                        let week = viewModel.weekSlider[index]

                            WeekView(week: week, currentDate: $viewModel.currentDate)
                                .padding(.horizontal, 15)
                                .tag(index)
                    }
                }
                .padding(.horizontal, -15)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 78)
            }
            .padding(15)
            .hSpace(.leading)
            
            .overlay(alignment: .topLeading) {
                TabBarButtonBack {
                    dismiss()
                }
            }
            .padding(.leading, 5)
            
            .overlay(alignment: .topTrailing) {
                Button(action: {
                    viewModel.isPresentedNewTask = true
                }) {
                    Image(systemName: "square.and.pencil.circle.fill")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 28))
                }
                .sheet(isPresented: $viewModel.isPresentedNewTask) {
                    CalendarAddTask(adminCalendarViewModel: Admin_CalendarViewModel.shared, adminViewModel: adminViewModel, masterModel: masterModel)
                        .presentationDetents([.height(540)])
                        .interactiveDismissDisabled()
                }
            }
            .padding(.trailing, 8)
            .onChange(of: viewModel.currentWeekIndex) {_,  new in
                if new == 0 || new == (viewModel.weekSlider.count - 1) {
                    viewModel.createWeek = true
                    
                    viewModel.paginationWeek()
                }
            }
        }
    }
}
