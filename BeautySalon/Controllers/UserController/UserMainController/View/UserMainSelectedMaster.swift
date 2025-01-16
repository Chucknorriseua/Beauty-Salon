//
//  UserMainSelectedMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/10/2024.
//

import SwiftUI

struct UserMainSelectedMaster: View {
    
    @StateObject var clientViewModel: ClientViewModel
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                
                LazyVStack {
                    ForEach(clientViewModel.mastersInRoom, id: \.self) { master in
                        NavigationLink(destination: AddNewMasterView(isShowButtonAdd: false, addMasterInRoom: master).navigationBarBackButtonHidden(true)) {
                            
                            User_MasterInToRoomCell(masterModel: master)
                        }.padding(.bottom, 14)
                    }
                }.padding(.top, 26)

            }.createBackgrounfFon()
            .scrollIndicators(.hidden)
        }
    }
}
