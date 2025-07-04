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
    
    @ObservedObject var adminCalendarViewModel: Admin_CalendarViewModel
    @ObservedObject var adminViewModel: AdminViewModel
    
    @State private var taskTitle: String = ""
    @State private var taskService: String = ""
    @State private var taskColor: String = "Color"
    @State private var isMenuProcedure: Bool = false
    @State private var isAddrocedure: Bool = false
    @State var masterModel: MasterModel
    @State private var selectedProcedures: [Procedure] = []
    
    
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
                    
                    SettingsTextField(text: $taskTitle, title: "Name client", width: geo.size.width * 1)
                    SettingsTextField(text: $taskService, title: "Service(nails or hair)", width: geo.size.width * 1)
                    
                }.font(.system(size: 16, weight: .medium))
                    .tint(Color.white)
                    .foregroundStyle(Color.white)
                
                VStack(spacing: 16) {
                    HStack() {
                        Spacer()
                        DatePicker("", selection: $adminCalendarViewModel.currentDate)
                            .datePickerStyle(.compact)
                        
                    }.padding(.horizontal, 8)
                    HStack {
                        VStack {
                            
                            let colors: [String] = (1...5).compactMap { index -> String in
                                return "Color\(index)"
                            }
                            HStack(spacing: 12) {
                                ForEach(colors, id:\.self) { color in
                                    Circle()
                                        .fill(Color(color))
                                        .frame(width: 32, height: 32)
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
                        Spacer()
                        Button {
                            withAnimation(.easeOut(duration: 0.5)) {
                                isMenuProcedure.toggle()
                            }
                        } label: {
                            Image(systemName: isMenuProcedure ? "minus.circle" : "plus.circle")
                                .font(.system(size: 36))
                                .foregroundStyle(Color.white)
                        }
                        .clipped()
                        .padding(.trailing, 8)
                    }.padding(.horizontal, 16)
                    if !adminViewModel.procedure.isEmpty {
                        VStack {
                            withAnimation {
                                AdminProcedureCell(adminViewModel: adminViewModel, selectedProcedures: $selectedProcedures)
                            }
                        }.frame(width: geo.size.width * 0.92, height: geo.size.height * 0.3)
                            .background(.ultraThinMaterial.opacity(0.6))
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay(alignment: .bottom) {
                                if !adminViewModel.procedure.isEmpty {
                                    HStack(spacing: 34) {
                                        Button {
                                            withAnimation(.easeOut(duration: 0.5)) {
                                                selectedProcedures.removeAll()
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Color.red.opacity(0.7))
                                        }
                                        
                                        Button {
                                            withAnimation(.easeOut(duration: 0.5)) {
                                                adminViewModel.removeProcedure(selectedProcedure: selectedProcedures)
                                                selectedProcedures.removeAll()
                                            }
                                        } label: {
                                            Image(systemName: "trash.circle")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Color.blue.opacity(0.7))
                                        }
                                        
                                    }
                                }
                                
                            }
                    }
                }.padding(.trailing, 6)
                HStack {
                    CustomButtonColor(bd: taskColor ,title: "Add") {
                        Task {
                           
                            let procedure = adminViewModel.adminProfile.procedure.filter { proc in
                                adminViewModel.procedure.contains(where: {$0.id == proc.id})
                            }
                          
                            let shedul = Shedule(id: UUID().uuidString, masterId: masterModel.masterID, nameCurrent: taskTitle, taskService: taskService, phone: "", nameMaster: masterModel.name, comment: "", creationDate: adminCalendarViewModel.currentDate, fcnTokenUser: masterModel.fcnTokenUser, tint: taskColor, timesTamp: Timestamp(date: adminCalendarViewModel.currentDate), procedure: procedure, latitude: masterModel.latitude, longitude: masterModel.longitude, nameSalonOrManster: "", phoneSalonOrMaster: "")

                            await Admin_CalendarViewModel.shared.addTaskShedule(masterID: masterModel.masterID, addTask: shedul)
                            adminViewModel.procedure.removeAll()
                            dismiss()
                        }
                    }
                }
                Spacer()
            })
            .ignoresSafeArea(.keyboard)
            .onAppear {
                adminViewModel.procedure.removeAll()
            }
            .onDisappear {
                adminViewModel.procedure.removeAll()
            }
            .frame(width: geo.size.width * 1)
            .sheetColor()
            .overlay(alignment: .bottom) {
                if isMenuProcedure {
                    VStack {
                        AdminChangeSelectView(adminViewModel: adminViewModel, addProcedure: $isAddrocedure, selectedProcedure: $selectedProcedures) {
                        }
                    }.padding(.horizontal, 14)
                }
            }
        }
    }
}

