//
//  User_AdminViewProfile.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/10/2024.
//

import SwiftUI


struct User_AdminViewProfile: View {
    
    @StateObject var clientViewModel: ClientViewModel
    @State private var isPriseList: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack {}
                        .createImageView(model: clientViewModel.adminProfile.image ?? "", width: geo.size.width * 0.6 / 2,
                                         height: geo.size.height * 0.68)
                    
                    Text(clientViewModel.adminProfile.name)
                        .font(.system(size: 22, weight: .bold))
    
                    Spacer()
                    VStack(alignment: .leading, spacing: 18) {
                        Button {
                            isPriseList = true
                        } label: {
                            VStack {
                                Image(systemName: "list.bullet.rectangle.portrait.fill")
                                    .font(.system(size: 28))
                                Text("Price list")
                                    .font(.system(size: 16, weight: .bold))
                            }.padding(.horizontal, 12)
                        }
                    }
                }
                .sheet(isPresented: $isPriseList, content: {
                    User_PriceList(clientViewModel: clientViewModel)
                        .foregroundStyle(Color.white)
                        .presentationDetents([.height(740)])
                })
                HStack {
                    Image(systemName: "phone.circle.fill")
                    Text(clientViewModel.adminProfile.phone)
                        .font(.system(size: 18, weight: .bold))
                }.onTapGesture {
                    let phoneNumber = "tel://" + clientViewModel.adminProfile.phone
                    if let url = URL(string: phoneNumber) {
                        UIApplication.shared.open(url)
                    }
                }
                
                Text("Administrator")
                    .font(.system(size: 14, weight: .medium).smallCaps())
                
            }.frame(width: geo.size.width * 1, height: geo.size.height * 1)
                .foregroundStyle(Color.yellow.opacity(0.8))
                .background(.ultraThinMaterial.opacity(0.3))
            
        }.frame(height: 140)
            .padding(.bottom, 8)
    }
}
