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
        GeometryReader { geometry in
            HStack(alignment: .center) {
                VStack {}
                    .createImageView(model: masterModel.image ?? "", width: geometry.size.width * 0.4 / 2,
                                     height: geometry.size.height * 0.6)
                VStack(alignment: .leading, spacing: 10) {
                    Text(masterModel.name)
                        .font(.system(size: 24, weight: .heavy))
                }
                Spacer()
                VStack {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 22, weight: .bold))
                }.padding(.trailing, 6)
                
            }.frame(width: geometry.size.width * 1, height: geometry.size.height * 0.8)
                .foregroundStyle(Color(hex: "F3E3CE"))
                .background(Color.init(hex: "#3e5b47").opacity(0.8), in: .rect(cornerRadius: 36))

        }
        .frame(height: 120)
        .padding(.vertical, -20)
        .padding(.leading, 6)
        .padding(.trailing, 6)
    }
}
