//
//  CellUser.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI
import SDWebImage

struct CellUser: View {
    
    @State var clientModel: Client? = nil
    @State private var isShowRecords: Bool = false
    
    var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(clientModel?.name ?? "no name")
                        .font(.system(size: 24, weight: .heavy))
                        .padding(.leading, 14)
                    
                    HStack {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 22))
                        Text(clientModel?.phone ?? "no phone")
                    }.onTapGesture {
                        let phoneNumber = "tel://" + (clientModel?.phone ?? "no phone")
                        if let url = URL(string: phoneNumber) {
                            UIApplication.shared.open(url)
                        }
                    }
                }.padding(.leading)
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                
                Spacer()
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90,
                           height: 90)
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(.trailing, 4)
            }.frame(height: 120)
                .setCellColor(radius: 24)
                .padding(.leading, 5)
                .padding(.trailing, 5)
   
    }
}
