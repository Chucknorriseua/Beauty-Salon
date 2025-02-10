//
//  CellAdminAddSheduleMasterList.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 16/10/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct CellAdminAddSheduleMasterList: View {
    
    @State var masterModel: MasterModel? = nil
    
    var body: some View {
        VStack {
            HStack {
                if let image = masterModel?.image, let url = URL(string: image) {
                    WebImage(url: url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                }
                
                Text(masterModel?.name ?? "no name")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white.opacity(0.9))
                Spacer()
            }.padding(.leading, 2)
                .background(Color.init(hex: "#3e5b47").opacity(0.6), in: .rect(cornerRadius: 24, style: .circular))
                .padding(.leading, 4)
                .padding(.trailing, 4)
        }
    }
}
