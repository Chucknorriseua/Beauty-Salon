//
//  UserCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 11/09/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserCell: View {
    
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("dsdsdsddjdjdjsasasasasasasas")
                        .font(.system(size: 24, weight: .heavy))
                        .padding(.leading, 14)
                    
                    HStack {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 22))
                        Text("masterAlhdjfhdsfjdsfjdsjkdsl")
                    }
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 20))
                        Text("masterAdjsdshdjshdjshdjshdjsdjsll")
                    }
                    
                }.padding(.leading)
                    .foregroundStyle(Color.white.opacity(0.92))
                    .lineLimit(2)
                
                Spacer()
                
                
                if let url = URL(string: "" ) {
                    
                    WebImage(url: url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 0.3,
                               height: geometry.size.height * 0.6)
                        .clipShape(.rect(cornerRadius: 24))
                        .padding(.trailing, 4)
                    
                } else {
                    Image("ab3")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 0.3,
                               height: geometry.size.height * 0.6)
                        .clipShape(.rect(cornerRadius: 24))
                        .padding(.trailing, 4)
                    
                }
            }.frame(height: geometry.size.height * 0.7)
                .background(.ultraThinMaterial.opacity(0.6), in: .rect(topLeadingRadius: 35, bottomTrailingRadius: 35))
                .padding(.leading, 5)
                .padding(.trailing, 5)
        }
        .frame(height: 200)
        .padding(.vertical, -26)
    }
}
