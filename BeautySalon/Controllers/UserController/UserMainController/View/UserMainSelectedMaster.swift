//
//  UserMainSelectedMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/10/2024.
//

import SwiftUI

struct UserMainSelectedMaster: View {
    
    @ObservedObject var clientViewModel: ClientViewModel
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                
                LazyVStack {
                    ForEach(clientViewModel.mastersInRoom, id: \.self) { master in
                        NavigationLink(destination: AddNewMasterView(isShowButtonAdd: false, addMasterInRoom: master, isShowMasterSend: false).navigationBarBackButtonHidden(true)) {
                            
                            User_MasterInToRoomCell(masterModel: master)
                        }.padding(.bottom, 6)
                    }
                }.padding(.top, 26)
                    .padding(.bottom, 90)
            }
            .scrollIndicators(.hidden)
        }
    }
}
