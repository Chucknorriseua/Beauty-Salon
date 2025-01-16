//
//  AddNewMasterCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 22/09/2024.
//

import SwiftUI


struct AddNewMasterCell: View {
    
    @State var addMasterInRoom: MasterModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(addMasterInRoom.name)
                        .font(.system(size: 20, weight: .heavy))
                        .padding(.leading, 8)

                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 20))
                        Text(addMasterInRoom.email)
                    }
                }.padding(.leading, 6)
                    .foregroundStyle(Color(hex: "F3E3CE"))
                    .lineLimit(2)
                
                Spacer()
                VStack {}
                    .createImageView(model: addMasterInRoom.image ?? "", width: geometry.size.width * 0.46 / 2,
                                     height: geometry.size.height * 0.46)
                
            }.frame(height: geometry.size.height * 0.54)
                .background(.ultraThinMaterial.opacity(0.8).opacity(0.7), in: .rect(cornerRadius: 36))
                .padding(.horizontal, 6)
        }
        .frame(height: 150)
        .padding(.vertical, -36)
    }
}
#Preview(body: {
    AddNewMasterCell(addMasterInRoom: MasterModel.masterModel())
})
