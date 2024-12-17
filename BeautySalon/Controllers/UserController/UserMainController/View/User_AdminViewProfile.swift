//
//  User_AdminViewProfile.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/10/2024.
//

import SwiftUI


struct User_AdminViewProfile: View {
    
    @ObservedObject var clientViewModel: ClientViewModel
    @State private var isShowSheet: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack {}
                        .createImageView(model: clientViewModel.adminProfile.image ?? "", width: geo.size.width * 0.6 / 2,
                                         height: geo.size.height * 0.68)
                    
                    Text(clientViewModel.adminProfile.name)
                        .font(.system(size: 24, weight: .bold))
    
                    Spacer()
                        Button {
                            isShowSheet = true
                        } label: {
                            Image(systemName: "newspaper.circle")
                                .font(.system(size: 48, weight: .bold))
                                .padding(.trailing, 15)
                                .padding(.top, 40)
                        }
                }.sheet(isPresented: $isShowSheet, content: {
                    UserSend_SheduleForAdmin(clientViewModel: clientViewModel)
                        .foregroundStyle(Color.white)
                        .presentationDetents([.height(400)])
                        .interactiveDismissDisabled()
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
