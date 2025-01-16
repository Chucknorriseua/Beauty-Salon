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
                        Text(procedure.price)
                            .foregroundStyle(Color.green.opacity(0.8))
                            .font(.system(size: 16, weight: .bold))
                    }
                }.foregroundStyle(Color.white)
                Spacer()
            }.padding(.vertical, 8)
                .padding(.leading, 4)
        }
        .background(.ultraThinMaterial.opacity(0.6))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal, 8)
    }
}
