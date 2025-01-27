//
//  User_MasterPriceList.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/01/2025.
//

import SwiftUI

struct User_MasterPriceList: View {
    
    @State var masterPrice: MasterModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                VStack {
                    Text("Price list for services")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.yellow.opacity(0.9))
                }
                ScrollView {
                    LazyVStack {
                        ForEach(masterPrice.procedure) { priceList in
                            User_PriceListCell(procedure: priceList)
                                .padding(.vertical, 4)
                        }
                    }.padding(.top, 10)
                }
            }.frame(width: geo.size.width * 1, height: geo.size.height * 1)
                .foregroundStyle(Color.yellow.opacity(0.8))
                .background(Color.init(hex: "#3e5b47").opacity(0.8))
        }
    }
}
