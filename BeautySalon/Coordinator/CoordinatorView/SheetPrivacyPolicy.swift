//
//  SheetPrivacyPolicy.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 21/03/2025.
//

import SwiftUI

struct SheetPrivacyPolicy: View {
    
    
    var body: some View {
        VStack {
            Text("Privacy Policy and Terms of Use")
                .foregroundColor(Color.yellow)
                .font(.system(size: 20, weight: .heavy))
                .padding(.top, 10)
            
            VStack(spacing: -10) {
                MainButtonSignIn(image: "hand.raised.square.fill", title: "Privacy Policy") {
                    if let url = URL(string: "https://sites.google.com/view/mybeautyhub/главная-страница/privacy-policy-for-my-beauty-hub") {
                        UIApplication.shared.open(url)
                    }
                }
                MainButtonSignIn(image: "hand.raised.square.fill", title: "Terms of Use") {
                    if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            Spacer()
        }
        .background(Color.init(hex: "#376889"))
    }
}

#Preview {
    SheetPrivacyPolicy()
}

