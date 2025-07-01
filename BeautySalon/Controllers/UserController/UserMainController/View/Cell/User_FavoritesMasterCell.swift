//
//  User_FavoritesMasterCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 23/02/2025.
//

import SwiftUI

struct User_FavoritesMasterCell: View {
    
    
    @State var master: MasterModel
    
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 30) {
                    VStack {}
                        .createImageView(model: master.image ?? "", width: 94, height: 94)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(master.name)
                                .foregroundStyle(Color.yellow)
                                .fontWeight(.heavy)
                                .lineLimit(4)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: 200)
                    .offset(x: -12)
                }
                .padding(.leading, 8)
                HStack(spacing: 2) {
                    Image(systemName: "phone.circle")
                    Text(master.phone)
                }
                .foregroundStyle(Color.white)
            }
        }
        .frame(width: 300, height: 150)
        .background(.ultraThinMaterial.opacity(0.4))
        .clipShape(.rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.init(hex: "#58A6DA"), Color.white]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .overlay(alignment: .topTrailing) {
            Button(action: {
                Task {
                    await ClientViewModel.shared.removeMyFavoritesMaster(master: master)
                }
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 28))
                
            })
            .offset(x: -6, y: 4)
        }
        .padding(.horizontal, 6)
    }
}

#Preview {
    User_FavoritesMasterCell(master: MasterModel.masterModel())
}
