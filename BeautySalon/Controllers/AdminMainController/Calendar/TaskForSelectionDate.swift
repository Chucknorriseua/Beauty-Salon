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
    @State private var isProcedure: Bool = false
    @State private var selectedProcedure: String? = nil
    var currentDate: Date
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    
    var body: some View {
        
        let tasks = viewModel.getTask(masterID: masterModel.masterID, date: viewModel.currentDate)
        if !tasks.isEmpty {
            ForEach(tasks) { task in
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                Text("\(task.nameCurrent)")
                                    .font(.system(size: 26, weight: .bold))
                            }.padding(.leading, 30)
                                .padding(.top, 6)
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
                            if selectedProcedure == task.id && isProcedure {
                                VStack {
                                    LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                                        ForEach(task.procedure, id: \.self) { item in
                                            Text(item.title)
                                                .frame(width: 110, height: 60, alignment: .center)
                                                .fontWeight(.heavy)
                                                .clipShape(.rect(cornerRadius: 16))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.white, lineWidth: 1)
                                                    
                                                )
                                            
                                        }
                                    }
                                }.padding(.horizontal, 8)
                            }
                        }
                        Spacer()
                    }.padding(.leading, 8)
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.5)) {
                            if selectedProcedure == task.id {
                                isProcedure.toggle()
                            } else {
                                selectedProcedure = task.id
                                isProcedure = true
                            }
                        }
                    }, label: {
                        VStack {
                            Image(systemName: "list.bullet.circle")
                                .foregroundStyle(Color.orange)
                                .font(.system(size: 24))
                              
                        }
                    }).padding(.bottom, 6)
                    
                }.frame(maxWidth: .infinity, maxHeight: isProcedure ? 420 : 180)
                    .background(task.tinColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.mint, .yellow]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .foregroundColor(.white)
                    .clipShape(.rect(cornerRadius: 22))
                    .padding(.horizontal, 8)
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
