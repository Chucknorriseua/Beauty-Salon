//
//  CellUser.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct CellUser: View {
    
    @State var clientModel: Client? = nil
    
    var body: some View {
        GeometryReader { geometry in
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
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 20))
                        Text(clientModel?.email ?? "")
                    }
                    
                }.padding(.leading)
                    .foregroundStyle(Color.white.opacity(0.92))
                    .lineLimit(2)
                
                Spacer()
                Image("ab3")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width * 0.25,
                           height: geometry.size.height * 0.2)
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(.trailing, 4)
            }.frame(height: geometry.size.height * 0.7)
                .background(Color.init(hex: "#3e5b47").opacity(0.7), in: .rect(cornerRadius: 36))
                .padding(.leading, 5)
                .padding(.trailing, 5)
        }
        .frame(height: 200)
        .padding(.vertical, -26)
    }
}
