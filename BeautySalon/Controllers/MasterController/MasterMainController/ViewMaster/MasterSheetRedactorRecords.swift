//
//  MasterSheetRedactorRecords.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 05/03/2025.
//

import SwiftUI
import FirebaseFirestore

struct MasterSheetRedactorRecords: View {
    
    @ObservedObject var masterVM: MasterViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selecetedRecord: Shedule?
    @State private var createNewDate: Date = Date()
    
    var body: some View {
        if let record = selecetedRecord {
            VStack {
                VStack(spacing: 20) {
                    Text("Change the client record")
                        .fontWeight(.bold)
                        .fontDesign(.serif)
                        .foregroundStyle(Color.yellow.opacity(0.9))
                    VStack(alignment: .center) {
                        DatePicker("", selection: $createNewDate, displayedComponents: [.hourAndMinute, .date])
                            .datePickerStyle(.compact)
                            .tint(Color.yellow)
                    }
                    .padding(.trailing, 14)
                    CustomButton(title: "Save change") {
                        let sendRecord = Shedule(id: record.id, masterId: record.masterId, nameCurrent: "", taskService: record.taskService, phone: record.phone, nameMaster: "", comment: record.comment, creationDate: createNewDate, fcnTokenUser: record.fcnTokenUser, tint: record.tint, timesTamp: Timestamp(date: Date()), procedure: [], latitude: record.latitude, longitude: record.longitude, nameSalonOrManster: masterVM.masterModel.name, phoneSalonOrMaster: masterVM.masterModel.phone)
                        
                        Task {
                            print("sendRecord", sendRecord)
                            await masterVM.updateRecordsFromClient(record: sendRecord, clientID: sendRecord.masterId)
                            dismiss()
                        }
                    }
                }
                .padding(.top, 10)
                Spacer()
            }
            .sheetColor()
            .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    MasterSheetRedactorRecords(masterVM: MasterViewModel.shared, selecetedRecord: .constant(Shedule.sheduleModel()))
}
