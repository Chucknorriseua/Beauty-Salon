//
//  MasterMainController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

struct MasterMainController: View {
    
    @StateObject var masterViewModel: MasterViewModel
    @StateObject var VmCalendar: MasterCalendarViewModel
 
    var body: some View {
        NavigationView(content: {
            GeometryReader { geo in
                
                VStack {
                    VStack {
                        
                        ShedulMasterHeader(masterCalendarViewModel: VmCalendar)
                    }.padding(.bottom, -20)
                    
                    ScrollView {
                        
                        ShedulCell(masterViewModel: VmCalendar, currentDate: VmCalendar.currentDate)
                        
                    }
                    .scrollIndicators(.hidden)
                    
                }.createBackgrounfFon()
                    .customAlert(isPresented: $masterViewModel.isAlert, hideCancel: true, message: masterViewModel.errorMassage, title: "Error", onConfirm: {}, onCancel: {})
                
            }
        }).onAppear {
       
            VmCalendar.setupWeeks()
            Task {
              await VmCalendar.getSheduleMaster()
            }
        }
        .refreshable {
            await VmCalendar.getSheduleMaster()
        }
    }
}
