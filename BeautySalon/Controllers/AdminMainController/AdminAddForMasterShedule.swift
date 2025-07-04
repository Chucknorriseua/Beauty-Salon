//
//  AdminMainController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

struct AdminAddForMasterShedule: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var adminViewModel: AdminViewModel
    @State var masterModel: MasterModel
    
    var body: some View {
        GeometryReader { geo in
            
            VStack {
                CalendarMainController(viewModel: Admin_CalendarViewModel.shared, adminViewModel: adminViewModel, masterModel: masterModel)  
            }
            .createBackgrounfFon()
            .swipeBackDismiss(dismiss: dismiss)
            
        }
        
    }
}
