//
//  CellColor.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 10/02/2025.
//

import SwiftUI

struct CellColor: ViewModifier {
    var radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
            .background(Color.white.opacity(0.01), in: .rect(cornerRadius: radius))
          
    }
}

extension View {
    func setCellColor(radius: CGFloat) -> some View {
        self.modifier(CellColor(radius: radius))
    }
}

struct ProcedureColor: ViewModifier {
    var radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
            .background(Color.init(hex: "#446C64"), in: .rect(cornerRadius: radius))
          
    }
}

extension View {
    func procedureColor(radius: CGFloat) -> some View {
        self.modifier(CellColor(radius: radius))
    }
}

struct SheetColor: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.init(hex: "#376889"), location: 0.4),
                        .init(color: Color.init(hex: "#17334D"), location: 0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    func sheetColor() -> some View {
        self.modifier(SheetColor())
    }
}
