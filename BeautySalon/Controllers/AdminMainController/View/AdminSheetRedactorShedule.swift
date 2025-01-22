//
//  AdminSheetRedactorShedule.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 17/01/2025.
//

import SwiftUI
import FirebaseFirestore

struct AdminSheetRedactorShedule: View {
    
    @StateObject var adminViewModel: AdminViewModel
    @Environment (\.dismiss) private var dismiss
    @State private var selectedProcedures: [Procedure] = []
    @State private var isMenuProcedure: Bool = false
    @State private var isAddrocedure: Bool = false
    @State private var masterName: String = ""
    @State private var createNewDate: Date = Date()
    @Binding var selecetedRecord: Shedule?
    
    var body: some View {
        if let record = selecetedRecord {
            VStack {
                VStack {
                    Text("Change the client record")
                        .fontWeight(.bold)
                        .fontDesign(.serif)
                        .foregroundStyle(Color.yellow.opacity(0.9))
                    VStack(alignment: .center) {
                        SettingsButton(text: $masterName, title: "Master: ", width: .infinity)
                        HStack {
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
                            .padding([.horizontal, .vertical], 10)
                        }
                        if !adminViewModel.procedure.isEmpty {
                            VStack {
                                withAnimation {
                                    AdminChangeRecordsView(adminViewModel: adminViewModel)
                                }
                            }.frame(maxWidth: .infinity, maxHeight: 400)
                                .background(.ultraThinMaterial.opacity(0.6))
                                .clipShape(.rect(cornerRadius: 12))
                                .padding(.horizontal, 6)
                                .overlay(alignment: .bottom) {
                                    if !adminViewModel.procedure.isEmpty {
                                        HStack(alignment: .center) {
                                            Button {
                                                withAnimation(.easeOut(duration: 0.5)) {
                                                    adminViewModel.removeProcedure(selectedProcedure: adminViewModel.procedure)
                                                    adminViewModel.procedure.removeAll()
                                                }
                                            } label: {
                                                Image(systemName: "trash.circle")
                                                    .font(.system(size: 32))
                                                    .foregroundStyle(Color.red.opacity(0.8))
                                            }
                                            
                                        }
                                    }
                                    
                                }
                        }
                        HStack {
                            VStack {
                                DatePicker("", selection: $createNewDate, displayedComponents: [.hourAndMinute, .date])
                                    .datePickerStyle(.compact)
                            }.padding(.trailing, 110)
                        }
                        CustomButton(title: "Save change") {
                            let sendRecord = Shedule(id: record.id, masterId: record.masterId, nameCurrent: record.nameCurrent, taskService: record.taskService, phone: record.phone, nameMaster: masterName, comment: record.comment, creationDate: createNewDate, tint: record.tint, timesTamp: Timestamp(date: Date()), procedure: adminViewModel.procedure)

                            Task {
                                print("sendRecord", sendRecord)
                                await adminViewModel.updateRecordsFromClient(record: sendRecord, id: sendRecord.id)
                                dismiss()
                            }
                        }
                    }
                }.padding(.top, 20)
                Spacer()
            }
            .background(Color.init(hex: "#3e5b47").opacity(0.8))
            .ignoresSafeArea(.all)
            .overlay(alignment: .bottom) {
                if isMenuProcedure {
                    VStack {
                        AdminSelectNewProcedureView(adminViewModel: adminViewModel, addProcedure: $isAddrocedure) {
                            withAnimation {
                                isMenuProcedure.toggle()
                            }
                        }
                    }.padding(.horizontal, 14)
                        .padding(.bottom, 30)
                }
            }.onAppear {
                masterName = record.nameMaster
                createNewDate = record.creationDate
                Task {
                    await fetchProcedureClient()
                }
            }
        }
    }
    private func fetchProcedureClient() async {
        adminViewModel.procedure.removeAll()
        if let procedure = selecetedRecord?.procedure {
            adminViewModel.procedure.append(contentsOf: procedure)
            print("RECORD: ", selecetedRecord?.nameMaster ?? "")
        }
    }
    
}

