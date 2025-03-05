//
//  User_SheetSheduleMasterHome.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 21/02/2025.
//

import SwiftUI
import FirebaseCore

struct User_SheetSheduleMasterHome: View {
    
    @State private var comment: String = ""
    @State private var taskService: String = ""
    @State private var selectedProcedures: [Procedure] = []
    @State private var selectedProceduresColor: [Procedure] = []
    @State private var isMenuProcedure: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var isAddrocedure: Bool = false
    @ObservedObject var clientViewModel = ClientViewModel.shared
    @State var masterModel: MasterModel
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Group {
                VStack(spacing: 20) {
                    SettingsTextField(text: $clientViewModel.clientModel.name, title: "Name", width: .infinity)
                    SettingsTextField(text: $clientViewModel.clientModel.phone, title: "Phone +(000)", width: .infinity)
                    SettingsTextField(text: $comment, title: "comment: ", width: .infinity)
                    SettingsTextField(text: $taskService, title: "Procedure: ", width: .infinity)
                        .overlay(alignment: .trailing) {
                            if !masterModel.procedure.isEmpty {
                                Button {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        isMenuProcedure.toggle()
                                    }
                                } label: {
                                    Image(systemName: isMenuProcedure ? "minus.circle" : "plus.circle")
                                        .foregroundStyle(Color.white)
                                        .font(.system(size: 32))
                                }
                                .clipped()
                                .padding(.trailing, 8)
                            }
                        }
                    VStack {
                        DatePicker("", selection: $clientViewModel.currentDate, displayedComponents: [.hourAndMinute, .date])
                            .datePickerStyle(.compact)
                    }.padding(.trailing, 110)
                }
                .padding(.top, 16)
                if !clientViewModel.procedure.isEmpty {
                    VStack {
                        withAnimation {
                            User_SelectProcedureCell(clientViewModel: clientViewModel, selectedProcedures: $selectedProcedures)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: 240)
                        .background(.ultraThinMaterial.opacity(0.6))
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal, 12)
                        .overlay(alignment: .bottom) {
                            if !clientViewModel.procedure.isEmpty {
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
                                            let saveSelected = selectedProcedures
                                            clientViewModel.removeProcedure(selectedProcedure: selectedProcedures)
                                            selectedProcedures.removeAll()
                                            DispatchQueue.main.async {
                                                selectedProceduresColor.removeAll { proc in
                                                    saveSelected.contains(where: {$0.id == proc.id})
                                                }
                                            }
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
                let sendRecordsTotal = String(
                    format: NSLocalizedString("sendRecords", comment: ""),
                    clientViewModel.totalCost
                )
                CustomButton(title: sendRecordsTotal) {
                    sendRecords()
                }
            }
            Spacer()
        }
        .sheetColor()
        .overlay(alignment: .bottom) {
            if isMenuProcedure {
                VStack {
                    User_MenuProcedureForeMasterView(clientViewModel: clientViewModel, addProcedure: $isAddrocedure, selectedProcedure: $selectedProceduresColor, masterModel: masterModel) {
                    }
                }.padding(.horizontal, 8)
                    .padding(.bottom, 20)
            }
        }
    }
    private func sendRecords() {
        let model = clientViewModel.clientModel
        
        let procedure = masterModel.procedure.filter { proc in
            clientViewModel.procedure.contains(where: {$0.id == proc.id})
        }
        let sendRecord = Shedule(id: UUID().uuidString, masterId: UUID().uuidString, nameCurrent: model.name, taskService: taskService, phone: model.phone, nameMaster: "", comment: comment, creationDate: clientViewModel.currentDate, fcnTokenUser: model.fcnTokenUser, tint: "Color1", timesTamp: Timestamp(date: Date()), procedure: procedure)
        
        
        Task {
            let titleEnter = String(
                format: NSLocalizedString("notification", comment: ""),
               masterModel.name)
            let subTitle = String(
                format: NSLocalizedString("notifiTitleMaster", comment: ""))
            await clientViewModel.send_SheduleForMaster(masterID: masterModel.id, record: sendRecord)
            NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
            clientViewModel.procedure.removeAll()
            dismiss()
        }
    }
}

#Preview {
    User_SheetSheduleMasterHome(clientViewModel: ClientViewModel.shared, masterModel: MasterModel.masterModel())
}
