//
//  CellMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI

struct CellMaster: View {
    
    @State var masterModel: MasterModel? = nil
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(masterModel?.name ?? "no name")
                        .font(.system(size: 24, weight: .heavy))
                        .padding(.leading, 14)
                    
                    HStack {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 22))
                        Text(masterModel?.phone ?? "no phone")
                    }.onTapGesture {
                        let phoneNumber = "tel://" + (masterModel?.phone ?? "no phone")
                        if let url = URL(string: phoneNumber) {
                            UIApplication.shared.open(url)
                        }
                    }
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 20))
                        Text(masterModel?.email ?? "")
                    }
                    
                }.padding(.leading)
                    .foregroundStyle(Color(hex: "F3E3CE"))
                    .lineLimit(2)
                
                Spacer()
                
                VStack {}
                    .createImageView(model: masterModel?.image ?? "", width: geometry.size.width * 0.56 / 2,
                                     height: geometry.size.height * 0.56)
 
            }.frame(height: geometry.size.height * 0.7)
                .background(.ultraThinMaterial.opacity(0.8), in: .rect(cornerRadius: 36))
                .padding(.leading, 5)
                .padding(.trailing, 5)
        }
        .frame(height: 200)
        .padding(.vertical, -26)
    }
}
