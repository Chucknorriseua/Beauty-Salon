//
//  CellListMasterDelete.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 07/10/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct CellListMasterDelete: View {
    
    @State var master: MasterModel
    @ObservedObject var adminViewModel: AdminViewModel
    
    var body: some View {
        VStack {
            HStack {
                if let image = master.image, let url = URL(string: image) {
                    WebImage(url: url)
                        .resizable()
                        .indicator(.activity)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.gray.opacity(0.7))
                }
                
                Text(master.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.white)
                Spacer()
                Button {
                    withAnimation(.easeOut) {
                        delete()
                    }
                } label: {
                    Image(systemName: "trash.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color.red)
                }
                .offset(x: 80)
            }.padding(.leading, 6)
                .padding(.all, 8)
                .animation(.easeOut, value: master)
        }
        .setCellColor(radius: 32)
        .frame(maxWidth: .infinity, maxHeight: 80)
        .padding(.horizontal, 12)
        .overlay(alignment: .trailing) {
            VStack {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.white)
            }
            .padding(.trailing, 18)
        }
    }
    
    private func delete() {
        Task {
           await adminViewModel.deleteMasterFromSalon(master: master)
        }
    }
}
