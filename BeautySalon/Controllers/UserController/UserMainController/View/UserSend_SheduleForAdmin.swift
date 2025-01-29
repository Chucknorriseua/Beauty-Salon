//
//  UserSend_SheduleForAdmin.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 06/10/2024.
//

import SwiftUI
import FirebaseFirestore

struct UserSend_SheduleForAdmin: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var clientViewModel: ClientViewModel
    
    @State private var serviceRecord: String = ""
    @State private var phoneRecord: String = ""
    @State private var nameMaster: String = ""
    @State private var comment: String = ""
    @State private var selected: String = ""
    @State private var isMenuProcedure: Bool = false
    @State private var isAddrocedure: Bool = false
    @State private var selectedProcedures: [Procedure] = []
    @State private var selectedProceduresColor: [Procedure] = []
    
    var body: some View {
        GeometryReader { geo in
            
            VStack(alignment: .center, spacing: 10,  content: {
                
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .tint(Color.white)
                        .font(.system(size: 20))
                        .padding(.all, 2)
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                }.background(Color.red, in: .rect(bottomLeadingRadius: 44, bottomTrailingRadius: 44))
                
                
                VStack(alignment: .leading, spacing: 10) {
                    SettingsButton(text: $clientViewModel.clientModel.phone, title: "Phone +(000)", width: geo.size.width * 1)
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .onChange(of: clientViewModel.clientModel.phone) { _, new in
                            clientViewModel.clientModel.phone = formatPhoneNumber(new)
                        }
                    SettingsButton(text: $serviceRecord, title: "Procedure make nails", width: geo.size.width * 1)
                        .overlay(alignment: .trailing) {
                            if !clientViewModel.adminProfile.procedure.isEmpty {
                                Button {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        isMenuProcedure.toggle()
                                    }
                                } label: {
                                    Image(systemName: isMenuProcedure ? "minus.circle" : "plus.circle")
                                        .font(.system(size: 32))
                                }
                                .clipped()
                                .padding(.trailing, 8)
                            }
                        }
                    if !clientViewModel.procedure.isEmpty {
                        VStack {
                            withAnimation {
                                User_SelectProcedureCell(clientViewModel: clientViewModel, selectedProcedures: $selectedProcedures)
                            }
                        }.frame(width: geo.size.width * 0.92, height: geo.size.height * 0.3)
                            .background(.ultraThinMaterial.opacity(0.6))
                            .clipShape(.rect(cornerRadius: 12))
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
                    HStack {
                        Text("Selected master: ")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                        
                        Picker("", selection: $selected) {
                            Image(systemName: "person.crop.circle.fill").tag("")
                            ForEach(clientViewModel.mastersInRoom, id: \.self) { master in
                                Text(master.name).tag(master.name)
                            }
                        }.pickerStyle(.menu)
                            .tint(Color(hex: "F3E3CE")).opacity(0.7)
                    }
                    SettingsButton(text: $comment, title: "comment: ", width: geo.size.width * 1)
                    
                }.padding(.leading, 0)
                    .font(.system(size: 12, weight: .medium))
                    .tint(Color.white)
                    .foregroundStyle(Color.white)
                
                HStack {
                    DatePicker("", selection: $clientViewModel.currentDate, displayedComponents: [.hourAndMinute, .date])
                        .datePickerStyle(.compact)
                       
                }.padding(.trailing, 90)
                HStack {
                    let sendRecordsTotal = String(
                        format: NSLocalizedString("sendRecords", comment: ""),
                        clientViewModel.totalCost
                    )
                    MainButtonSignIn(image: "pencil.line", title: sendRecordsTotal, action: {
                        sendRecords()
                    })
                }
                Spacer()
            }).frame(width: geo.size.width * 1, height: geo.size.height * 1)
                .onDisappear {
                    clientViewModel.totalCost = 0.0
                    clientViewModel.procedure.removeAll()
                }
                .background(Color.init(hex: "#3e5b47").opacity(0.8))
                .ignoresSafeArea(.all)
                .overlay(alignment: .bottom) {
                    if isMenuProcedure {
                        VStack {
                            User_MenuProcedureView(clientViewModel: clientViewModel, addProcedure: $isAddrocedure, selectedProcedure: $selectedProceduresColor) {
                            }
                        }.padding(.horizontal, 8)
                            .padding(.bottom, 20)
                    }
                }
        }
    }
    private func sendRecords() {
        let model = clientViewModel.clientModel
        
        let procedure = clientViewModel.adminProfile.procedure.filter { proc in
            clientViewModel.procedure.contains(where: {$0.id == proc.id})
        }
        let sendRecord = Shedule(id: UUID().uuidString, masterId: UUID().uuidString, nameCurrent: model.name, taskService: serviceRecord, phone: model.phone, nameMaster: selected, comment: comment, creationDate: clientViewModel.currentDate, tint: "Color1", timesTamp: Timestamp(date: Date()), procedure: procedure)
        
        
        Task {
            let titleEnter = String(
                format: NSLocalizedString("notification", comment: ""),
                clientViewModel.adminProfile.name)
            let subTitle = String(
                format: NSLocalizedString("notifiTitle", comment: ""))
            await clientViewModel.send_SheduleForAdmin(adminID: clientViewModel.adminProfile.adminID, record: sendRecord)
            NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
            clientViewModel.procedure.removeAll()
            dismiss()
        }
    }
}

#Preview(body: {
    UserSend_SheduleForAdmin(clientViewModel: ClientViewModel.shared)
})
