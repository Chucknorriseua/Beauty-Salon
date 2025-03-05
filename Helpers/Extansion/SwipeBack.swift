//
//  SwipeBack.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 21/11/2024.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func swipeBack(coordinator: CoordinatorView) -> some View {
       self
        .gesture(
            DragGesture()
                .onEnded({ end in
                    if end.translation.width > 150 {
                        coordinator.pop()
                    }
                })
        )
    }
    @ViewBuilder
    func swipeBackDismiss(dismiss: DismissAction) -> some View {
       self
        .gesture(
            DragGesture()
                .onEnded({ end in
                    if end.translation.width > 150 {
                       dismiss()
                    }
                })
        )
    }
}
