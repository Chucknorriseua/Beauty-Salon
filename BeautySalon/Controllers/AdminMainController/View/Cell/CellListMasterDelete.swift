//
//  CellListMasterDelete.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 07/10/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct CellListMasterDelete: View {
    
    @State var master: MasterModel? = nil
    
    var body: some View {
        VStack {
            HStack {
                if let image = master?.image, let url = URL(string: image) {
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
                
                Text(master?.name ?? "no name")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.yellow.opacity(0.9))

            }.padding(.leading, 6)
        }
    }
}
