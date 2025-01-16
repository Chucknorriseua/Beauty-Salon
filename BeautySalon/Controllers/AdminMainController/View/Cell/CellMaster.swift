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
            HStack(spacing: -26) {
                VStack {}
                    .createImageView(model: masterModel?.image ?? "", width: geometry.size.width * 0.36 / 2,
                                     height: geometry.size.height * 0.46)
                VStack {
                    Text(masterModel?.name ?? "")
                        .font(.system(size: 24, weight: .heavy))
                        .padding(.leading, 14)
                }.padding(.leading)
                    .foregroundStyle(Color(hex: "F3E3CE"))
                    .lineLimit(2)
                Spacer()
            }.frame(height: geometry.size.height * 0.5)
                .background(.ultraThinMaterial.opacity(0.8), in: .rect(cornerRadius: 36))
                .padding(.horizontal, 6)
                .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(hex: "F3E3CE"))
                        .fontWeight(.bold)
                        .padding(.trailing, 16)
                }
        }
        .frame(height: 150)
        .padding(.vertical, -36)
    }
}

#Preview {
    CellMaster(masterModel: MasterModel.masterModel())
}
