//
//  MasterWeekView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 18/09/2024.
//

import SwiftUI

struct MasterWeekView: View {
    
    var week: [Date.WeekDay]
    @Binding var currentDate: Date
    
    var body: some View {
        HStack(spacing: 14) {
            ForEach(week) { day in
                VStack(spacing: 8) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(.yellow)
                    
                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .black)
                        .frame(width: 35, height: 35)
                        .background {
                            if isSameDate(day.date, currentDate) {
                                Circle().fill(Color.yellow)
                            }
                            if day.date.isToday {
                                Circle()
                                    .fill(.cyan)
                                    .frame(width: 5, height: 5)
                                    .padding(.top, 20)
                                    .offset(y: 12)
                            }
                        }
                        .background(.white.shadow(.drop(radius: 1)), in: .circle)
                }
                .onTapGesture {
                    withAnimation(.snappy) {
                        currentDate = day.date
                    }
                }
            }
        }
    }
}

