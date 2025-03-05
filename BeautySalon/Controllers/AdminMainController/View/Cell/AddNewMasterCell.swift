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
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(addMasterInRoom.name)
                        .font(.system(size: 20, weight: .heavy))
                        .padding(.leading, 8)

                    HStack {
                        Image(systemName: "phone.down.circle")
                            .font(.system(size: 20))
                        Text(addMasterInRoom.phone)
                    }
                }.padding(.leading, 6)
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                
                Spacer()
                VStack {}
                    .createImageView(model: addMasterInRoom.image ?? "", width: 80,
                                     height: 80)
                
            }.frame(height: 100)
                .setCellColor(radius: 36)
                .padding(.horizontal, 6)
        }
    }

#Preview(body: {
    AddNewMasterCell(addMasterInRoom: MasterModel.masterModel())
})
