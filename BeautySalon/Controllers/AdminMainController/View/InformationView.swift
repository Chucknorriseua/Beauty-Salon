//
//  InformationView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 23/02/2025.
//

import SwiftUI

struct InformationView: ViewModifier {
    
    @Binding var isShowInfo: Bool
    let image: String
    let text: String
    let dismiss: () -> ()
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isShowInfo)
            if isShowInfo {
                VStack {
                    VStack(alignment: .center, spacing: 24) {
                        Image(systemName: "info.bubble")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 32))
                        
                        VStack {
                            Image(image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                        }
                        
                        VStack {
                            Text(LocalizedStringKey(text))
                                .font(.system(size: 22, weight: .heavy))
                                .fontDesign(.serif)
                                .foregroundStyle(Color.white)
                                .lineLimit(14)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 300)
        
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: 400)
                .background(.ultraThinMaterial.opacity(0.9), in: .rect(topLeadingRadius: 44, bottomTrailingRadius: 44))
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 44, bottomTrailingRadius: 44)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.init(hex: "#58A6DA"), Color.white]),
                                startPoint: .top,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                )
                .padding(.horizontal, 14)
                .overlay(alignment: .topTrailing) {
                    Button {
                        dismiss()
                    } label: {
                     Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 32))
                    }
                    .offset(x: -16)
                }
            }
        }
    }
}

extension View {
    func informationView(isShowInfo: Binding<Bool>, image: String, text: String, dismiss: @escaping () -> Void) -> some View {
        self.modifier(InformationView(isShowInfo: isShowInfo, image: image, text: text, dismiss: dismiss))
    }
}

//#Preview {
//    InformationView()
//}
