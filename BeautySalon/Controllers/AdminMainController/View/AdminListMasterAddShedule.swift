//
//  AdminListMasterAddShedule.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 16/10/2024.
//

import SwiftUI

struct AdminListMasterAddShedule: View {
    
    @ObservedObject var adminViewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selecetedRecord: Shedule?
    
    var body: some View {
        VStack {
            let send = String(
                format: NSLocalizedString("sendRecord", comment: ""),
                selecetedRecord?.nameCurrent ?? ""
            )
            Text(send)
                .font(.system(size: 20, weight: .bold))
                .fontDesign(.serif)
                .foregroundStyle(Color.yellow)
            Group {
                ScrollView(.vertical) {
                    
                    LazyVStack(content: {
                        ForEach(adminViewModel.addMasterInRoom, id: \.self) { master in
                            Button {
                                if let selected = selecetedRecord {
                                    Task {
                                        await adminViewModel.sendCurrentMasterRecord(masterID: master.masterID, shedule: selected)
                                        let titleEnter = String(
                                            format: NSLocalizedString("sendRecordFormaster", comment: ""),
                                            master.name)
                                        let subTitle = String(
                                            format: NSLocalizedString("sendRecordFormasterTitle", comment: ""),
                                            master.name)
                                        NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    dismiss()
                                }
                            } label: {
                                CellAdminAddSheduleMasterList(masterModel: master)
                            }
                        }
                    })
                }
            }
            Spacer()
        }
        .sheetColor()
            .ignoresSafeArea()
    }
}
