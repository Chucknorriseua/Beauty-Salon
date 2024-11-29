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
    
    @StateObject var clientViewModel: ClientViewModel
    
    @State private var serviceRecord: String = ""
    @State private var phoneRecord: String = ""
    @State private var nameMaster: String = ""
    @State private var comment: String = ""
    @State private var selected: String = ""
    
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
                    SettingsButton(text: $serviceRecord, title: "Service- make nails", width: geo.size.width * 1)
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
                DatePicker("", selection: $clientViewModel.currentDate)
                            .datePickerStyle(.compact)
                }.padding(.trailing, 110)
                HStack {
               
                    MainButtonSignIn(image: "pencil.line", title: "Send record", action: {
                        
                        let sendRecord = Shedule(id: UUID().uuidString, masterId: UUID().uuidString, nameCurrent: clientViewModel.clientModel.name, taskService: serviceRecord, phone: clientViewModel.clientModel.phone, nameMaster: selected, comment: comment, creationDate: clientViewModel.currentDate, tint: "Color1", timesTamp: Timestamp(date: Date()))
                    
                        Task {
                            await clientViewModel.send_SheduleForAdmin(adminID: clientViewModel.adminProfile.adminID, record: sendRecord)
                            NotificationController.sharet.notify(title: "You send record for \(clientViewModel.adminProfile.name)", subTitle: "your record has been sent to the admin, please wait for the admin to contact you", timeInterval: 1)
                            dismiss()
                        }
                    })
                }
                Spacer()
            })
            .background(Color.init(hex: "#3e5b47").opacity(0.8))
            .ignoresSafeArea(.all)
        }.frame(width: 420)
    }
}
