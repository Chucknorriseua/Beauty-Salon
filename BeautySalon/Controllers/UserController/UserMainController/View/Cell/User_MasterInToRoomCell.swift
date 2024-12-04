//
//  User_MasterInToRoomCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/10/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct User_MasterInToRoomCell: View {
    
    @State var masterModel: MasterModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                VStack {
                    if let url = URL(string: masterModel.image ?? "") {
                        
                        WebImage(url: url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width * 0.2,
                                   height: geometry.size.height * 0.6)
                            .clipShape(Circle())
                            .padding(.leading, 6)
                        
                    } else {
                        Image("ab3")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width * 0.2,
                                   height: geometry.size.height * 0.6)
                            .clipShape(Circle())
                            .padding(.leading, 6)
                        
                    }
                }.overlay(content: {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                })

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
