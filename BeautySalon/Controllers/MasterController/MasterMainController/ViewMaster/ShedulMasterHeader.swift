//
//  ShedulMasterHeader.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 23/08/2024.
//

import SwiftUI

struct ShedulMasterHeader: View {
    
    @ObservedObject var masterCalendarViewModel: MasterCalendarViewModel
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(masterCalendarViewModel.currentDate.format("MMMM"))
                    Text(masterCalendarViewModel.currentDate.format("YYYY"))
                }
                .foregroundStyle(Color.yellow)
                .font(.title.bold())
                
                Text(masterCalendarViewModel.currentDate.formatted(date: .complete, time: .omitted))
                    .foregroundStyle(Color.white)
                    .font(.callout)
                
                TabView(selection: $masterCalendarViewModel.currentWeekIndex) {
                    ForEach(masterCalendarViewModel.weekSlider.indices, id:\.self) { index in
                        let week = masterCalendarViewModel.weekSlider[index]
                        MasterWeekView(week: week, currentDate: $masterCalendarViewModel.currentDate)
                            .padding(.horizontal, 15)
                            .tag(index)
                    }
                }
                .padding(.horizontal, -15)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 78)
            }
            .padding(.bottom, 14)
            .hSpace(.leading)
            .padding(.trailing, 8)
            .onChange(of: masterCalendarViewModel.currentWeekIndex) {_, new in
                if new == 0 || new == (masterCalendarViewModel.weekSlider.count - 1) {
                    masterCalendarViewModel.createWeek = true
                    
                }
                masterCalendarViewModel.paginationWeek()
            }
        }
    }
}
