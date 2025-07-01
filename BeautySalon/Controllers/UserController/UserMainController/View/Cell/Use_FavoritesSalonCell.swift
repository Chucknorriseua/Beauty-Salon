//
//  Use_FavoritesSalonCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 23/02/2025.
//

import SwiftUI

struct Use_FavoritesSalonCell: View {
    
    @State var salon: Company_Model
    
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 30) {
                    VStack {}
                        .createImageView(model: salon.image ?? "", width: 94, height: 94)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(salon.companyName)
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
                    Text(salon.phone)
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
                    await ClientViewModel.shared.removeFavoritesSalon(salon: salon)
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
    Use_FavoritesSalonCell(salon: Company_Model.companyModel())
}
