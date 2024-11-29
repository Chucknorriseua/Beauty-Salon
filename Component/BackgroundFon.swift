//
//  BackgroundFon.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

struct BackgroundFon: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
            .background(
                LinearGradient(colors: [Color.gray.opacity(0.3), Color.init(hex: "#3e5b47").opacity(0.9)],
                               startPoint: .topLeading,
                               endPoint: .bottomLeading)
            )
    }
}

extension View {
    func createBackgrounfFon() -> some View {
        self.modifier(BackgroundFon())
    }
}
