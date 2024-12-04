//
//  AdminListMasterAddShedule.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 16/10/2024.
//

import SwiftUI

struct AdminListMasterAddShedule: View {
    
    @ObservedObject var adminViewModel: AdminViewModel
    @Environment (\.dismiss) private var dismiss
    @Binding var selecetedRecord: Shedule?
    
    var body: some View {
        VStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .tint(Color.white)
                    .font(.system(size: 20))
                    .padding(.all, 2)
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
            }.background(Color.red, in: .rect(bottomLeadingRadius: 44, bottomTrailingRadius: 44))
            
            Text("Send record: \(selecetedRecord?.nameCurrent ?? "")")
                .fontWeight(.bold)
                .foregroundStyle(Color.yellow.opacity(0.8))
            Group {
                ScrollView(.vertical) {
                    
                    LazyVStack(content: {
                        ForEach(adminViewModel.addMasterInRoom, id: \.self) { master in
                            Button {
                                if let selected = selecetedRecord {
                                    Task {
                                        await adminViewModel.sendCurrentMasterRecord(masterID: master.masterID, shedule: selected)
                                        await adminViewModel.deleteRecord(record: selected)
                                        NotificationController.sharet.notify(title: "The record has been sent", subTitle: "The recording has been sent to the master: \(master.name) 🙍‍♀️", timeInterval: 1)
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    dismiss()
                                }
                            } label: { CellAdminAddSheduleMasterList(masterModel: master) }
                        }
                    })
                }
            }
            Spacer()
        }.background(Color.init(hex: "#3e5b47").opacity(0.9))
            .ignoresSafeArea()
    }
}
