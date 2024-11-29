//
//  CalendarAddTask.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI
import FirebaseFirestore

struct CalendarAddTask: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var adminCalendarViewModel: Admin_CalendarViewModel
    
    @State private var taskTitle: String = ""
    @State private var taskService: String = ""
    @State private var taskColor: String = "Color"
    @State var masterModel: MasterModel
    
    var body: some View {
        GeometryReader { geo in
            
            VStack(alignment: .center, spacing: 20,  content: {
                
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .tint(Color.white)
                        .font(.system(size: 20))
                        .padding(.all, 2)
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                }.background(Color.red, in: .rect(bottomLeadingRadius: 44, bottomTrailingRadius: 44))
                
                
                VStack(alignment: .leading) {
                    
                    SettingsButton(text: $taskTitle, title: "Name client", width: geo.size.width * 1)
                    SettingsButton(text: $taskService, title: "Service(nails or hair)", width: geo.size.width * 1)
                    
                }.font(.system(size: 16, weight: .medium))
                    .tint(Color.white)
                    .foregroundStyle(Color.white)
                
                HStack(spacing: -6) {
                    HStack() {
                        
                        DatePicker("", selection: $adminCalendarViewModel.currentDate)
                            .datePickerStyle(.compact)
                        
                    }.padding(.trailing)
                    
                    VStack {
                        
                        let colors: [String] = (1...5).compactMap { index -> String in
                            return "Color\(index)"
                        }
                        HStack(spacing: 6) {
                            ForEach(colors, id:\.self) { color in
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 24, height: 24)
                                    .background(content: {
                                        Circle()
                                            .stroke(lineWidth: 6)
                                            .foregroundStyle(Color.white)
                                            .opacity(taskColor == color ? 1 : 0)
                                    }).contentShape(.rect)
                                    .onTapGesture {
                                        withAnimation(.snappy) {
                                            taskColor = color
                                        }
                                    }
                            }
                        }
                    }
                    
                }.padding(.trailing, 6)
                HStack {
                    CustomButtonColor(bd: taskColor ,title: "Add") {
                        Task {
                            
                            let shedul = Shedule(id: UUID().uuidString, masterId: masterModel.masterID, nameCurrent: taskTitle, taskService: taskService, phone: "", nameMaster: "", comment: "", creationDate: adminCalendarViewModel.currentDate, tint: taskColor, timesTamp: Timestamp(date: adminCalendarViewModel.currentDate))

                            await Admin_CalendarViewModel.shared.addTaskShedule(masterID: masterModel.masterID, addTask: shedul)
                        }
                        
                        
                        dismiss()
                    }
                }
                Spacer()
            })
            .frame(width: geo.size.width * 1)
                .padding(.trailing, 6)
            .background(Color.init(hex: "#3e5b47").opacity(0.8))
        }
    }
}
