//
//  CalendarControllerView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI

struct TasksForSelectedDate: View {
    
    @ObservedObject var viewModel: Admin_CalendarViewModel
    @State var masterModel: MasterModel
    var currentDate: Date
    
    var body: some View {
        
        let tasks = viewModel.getTask(masterID: masterModel.masterID, date: viewModel.currentDate)
        
        if !tasks.isEmpty {
            
            ForEach(tasks) { task in
                HStack {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                            Text("\(task.nameCurrent)")
                                .font(.system(size: 26, weight: .bold))
                        }.padding(.leading, 30)
                        
                        HStack {
                            Image(systemName: "list.bullet.clipboard.fill")
                            Text("- \(task.taskService)")
                                .font(.system(size: 19, weight: .medium))
                        }
                        
                        HStack {
                            Image(systemName: "clock.circle.fill")
                            Text("\(format(task.creationDate))")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }.padding(.leading, 8)
                        .foregroundStyle(Color.white)
                    Spacer()
                }.frame(width: UIScreen.main.bounds.width - 20, height: 160)
                    .background(task.tinColor, in: .rect(cornerRadius: 44))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            Task {
                                await viewModel.removeSheduleCurrentMaster(shedule: task, clientID: masterModel.masterID)
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.white.opacity(0.8))
                                .font(.system(size: 28))
                              
                        }.padding(.trailing, 10)
                            .padding(.top, 12)

                    }
                
            }
            
        }
    }
    
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "  HH : mm"
        return formatter.string(from: date)
    }
}
