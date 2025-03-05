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
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.init(hex: "#17354F"), location: 0.0),   // В начале
                        .init(color: Color.init(hex: "#C9B2A1"), location: 0.3),  // На 30%
                        .init(color: Color.init(hex: "#4786B0"), location: 0.4), // На 60%
                        .init(color: Color.init(hex: "#12283E"), location: 1.0) // В конце
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

extension View {
    func createBackgrounfFon() -> some View {
        self.modifier(BackgroundFon())
    }
}

