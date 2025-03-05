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
        VStack {
            
            HStack(spacing: -26) {
                VStack {}
                    .createImageView(model: masterModel?.image ?? "", width: 66,
                                     height: 66)
                VStack {
                    Text(masterModel?.name ?? "")
                        .font(.system(size: 24, weight: .heavy))
                        .padding(.leading, 14)
                }.padding(.leading)
                    .lineLimit(2)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.white)
                    .fontWeight(.bold)
                    .padding(.trailing, 16)
            }
            .setCellColor(radius: 36)
        }
        .frame(height: 90)
        .foregroundStyle(Color.white)
        .padding(.horizontal, 6)
        }
    }



#Preview {
    CellMaster(masterModel: MasterModel.masterModel())
}
