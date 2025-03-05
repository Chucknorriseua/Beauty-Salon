//
//  User_PriceListCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 12/01/2025.
//

import SwiftUI

struct User_PriceListCell: View {
    
    @State var procedure: Procedure
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(procedure.title)
                        .padding(.leading, 14)
                        .font(.system(size: 24, weight: .bold))
                    Text(procedure.description)
                        .fontWidth(.compressed)
                    HStack(spacing: 2) {
                        Spacer()
                        Text("price: ")
                        HStack {
                            Text(procedure.price)
                                .foregroundStyle(Color.blue)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.all, 8)
                        }
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: 18))
                    }
     
                }.foregroundStyle(Color.white)
                Spacer()
            }.padding(.vertical, 8)
                .padding(.leading, 4)
        }
        .setCellColor(radius: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.init(hex: "#58A6DA"), Color.white]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 8)
    }
}
