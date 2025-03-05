//
//  User_MasterInToRoomCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/10/2024.
//

import SwiftUI

struct User_MasterInToRoomCell: View {
    
    @State var masterModel: MasterModel
    
    var body: some View {
            HStack(alignment: .center) {
                VStack {}
                    .createImageView(model: masterModel.image ?? "", width: 74,
                                     height: 74)
                VStack(alignment: .leading, spacing: 10) {
                    Text(masterModel.name)
                        .font(.system(size: 24, weight: .heavy))
                }
                Spacer()
                VStack {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 22, weight: .bold))
                }.padding(.trailing, 6)
                
            }.frame(maxWidth: .infinity, maxHeight: 150)
            .foregroundStyle(Color.white)
                .setCellColor(radius: 36)


        .padding(.leading, 6)
        .padding(.trailing, 6)
    }
}
