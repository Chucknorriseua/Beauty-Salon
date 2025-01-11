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
                        .font(.system(size: 24, weight: .heavy))
                        .padding(.leading, 14)
                    
                    HStack {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 22))
                        Text(addMasterInRoom.phone)
                    }.onTapGesture {
                        let phoneNumber = "tel://" + addMasterInRoom.phone
                        if let url = URL(string: phoneNumber) {
                            UIApplication.shared.open(url)
                        }
                    }
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
                    .createImageView(model: addMasterInRoom.image ?? "", width: geometry.size.width * 0.56 / 2,
                                     height: geometry.size.height * 0.56)
                
            }.frame(height: geometry.size.height * 0.77)
                .background(.ultraThinMaterial.opacity(0.8).opacity(0.7), in: .rect(cornerRadius: 36))
                .padding(.leading, 5)
                .padding(.trailing, 5)
        }
        .frame(height: 200)
        .padding(.vertical, -26)
    }
}
