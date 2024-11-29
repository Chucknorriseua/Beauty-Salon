//
//  CompanyAllCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct CompanyAllCell: View {
    
    @State var companyModel: Company_Model? = nil
    
    var body: some View {
        
        GeometryReader { geo in
            
            VStack {
                VStack(spacing: 0) {
                    if let image = companyModel?.image, let url = URL(string: image) {
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.6)
                            .clipShape(.rect(topLeadingRadius: 60))
                    } else {
                        Image("ab1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.6)
                            .clipShape(.rect(topLeadingRadius: 42))
                    }
                    
                    
                    ZStack(alignment: .center) {
                        
                        VStack(alignment: .center, spacing: 2) {
                            //                    Name
                            Text(companyModel?.companyName ?? "no found company")
                                .font(.system(size: 24, weight: .heavy))
                                .lineLimit(4)
                            
                            VStack(spacing: 6) {
                                //                     Description
                                Text(companyModel?.description ?? "no description")
                                    .fontWeight(.medium)
                                    .lineLimit(10)
                            }.frame(width: geo.size.width * 0.95, height: geo.size.height * 0.20)
                                .multilineTextAlignment(.leading)
                            VStack {
                                Text(companyModel?.adress ?? "no adress")
                                    .font(.system(size: 18, weight: .heavy))
                                    .lineLimit(2)
                                Spacer()
                            }.frame(width: geo.size.width * 0.95, height: geo.size.height * 0.04)
                            
                            //                Email and phone
                            VStack(alignment: .center, spacing: 5) {
                                HStack {
                                    Image(systemName: "phone.circle.fill")
                                        .font(.system(size: 22))
                                    Text("\(companyModel?.phone ?? "no phone")")
                                }.onTapGesture {
                                    let phoneNumber = "tel://" + (companyModel?.phone ?? "no phone")
                                    if let url = URL(string: phoneNumber) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 20))
                                    Text(" \(companyModel?.email ?? "no email")")
                                }
                            }
                        }.multilineTextAlignment(.center)
                        
                    }
                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.52)
                    .background(.ultraThinMaterial.opacity(0.7), in: .rect(bottomTrailingRadius: 42))
                    
                }
                
            }.foregroundStyle(Color(hex: "F3E3CE"))
                .padding(.leading, 10)
        }.frame(height: 360)

    }
}
