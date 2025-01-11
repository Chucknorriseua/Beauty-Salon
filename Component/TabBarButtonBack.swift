//
//  TabBarButtonBack.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 15/10/2024.
//

import SwiftUI

struct TabBarButtonBack: View {
    
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.init(hex: "#3e5b47").opacity(0.8))
                Text("Back")
                    .font(.system(size: 18).bold())
            }.foregroundStyle(Color.white)
        })
    }
}
