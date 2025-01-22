//
//  SettingsButton.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/09/2024.
//

import SwiftUI

@available(iOS 16.0, *)
struct SettingsButton: View {
    
    var text: Binding<String>
    var title: String
    var width: CGFloat
    
    var body: some View {
        Group {
            
            TextField(text: text) {
                Text(LocalizedStringKey(title))
                    .monospaced()
                    .foregroundStyle(Color(hex: "F3E3CE").opacity(0.4))
                    .fontWeight(.semibold)
            }
        }
        .foregroundStyle(Color(hex: "F3E3CE"))
        .padding(.leading, 4)
        .frame(width: UIScreen.main.bounds.width - 30, height: 50)
        .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
    }
}
