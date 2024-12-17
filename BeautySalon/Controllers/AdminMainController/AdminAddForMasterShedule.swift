//
//  AdminMainController.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

struct AdminAddForMasterShedule: View {
    
    @Environment (\.dismiss) var dismiss
    
    @StateObject var adminViewModel: AdminViewModel
    @State var masterModel: MasterModel
    
    var body: some View {
        GeometryReader { geo in
            
            VStack {
                CalendarMainController(viewModel: Admin_CalendarViewModel.shared, masterModel: masterModel)  
            }
            .createBackgrounfFon()
            .swipeBackDismiss(dismiss: dismiss)
        }
        
    }
}
