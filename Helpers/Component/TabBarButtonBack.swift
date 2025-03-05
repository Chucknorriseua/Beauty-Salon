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
                Image(systemName: "chevron.backward")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.white)
     
            }
        })
    }
}
