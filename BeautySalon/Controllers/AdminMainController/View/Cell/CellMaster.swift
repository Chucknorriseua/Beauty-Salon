//
//  CellMaster.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI
import SDWebImageSwiftUI

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
                
                VStack {
                    if let url = URL(string: masterModel?.image ?? "" ) {
                        
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width * 0.3,
                                   height: geometry.size.height * 0.6)
                            .clipShape(Circle())
                            .padding(.trailing, 4)
                        
                    } else {
                        Image("ab3")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width * 0.3,
                                   height: geometry.size.height * 0.6)
                            .clipShape(Circle())
                            .padding(.trailing, 4)
                    }
                }.overlay(content: {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                })
 
            }.frame(height: geometry.size.height * 0.7)
                .background(Color.init(hex: "#3e5b47").opacity(0.7), in: .rect(cornerRadius: 36))
                .padding(.leading, 5)
                .padding(.trailing, 5)
        }
        .frame(height: 200)
        .padding(.vertical, -26)
    }
}
