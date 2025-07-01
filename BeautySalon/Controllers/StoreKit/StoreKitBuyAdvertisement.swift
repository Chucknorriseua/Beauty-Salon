//
//  StoreKitBuyAdvertisement.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 04.05.2025.
//

import SwiftUI
import StoreKit

struct StoreKitBuyAdvertisement: View {
    
    @EnvironmentObject var storeKitView: StoreViewModel
    @State var isPurchased: Bool = false
    @State private var isShowBuySub: Bool = false
    @Binding var isXmarkButton: Bool
    @AppStorage("firstSignIn") var firstSignIn: Bool = false
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 40) {
                Image("ads")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 124, height: 124)
                
                VStack {
                    Text("You see ads so we can continue to develop the app. If you want to use without ads - subscribe and enjoy full comfort!")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 18, weight: .heavy))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
             
                ForEach(storeKitView.subscriptionsAdmin) { product in
                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            Task { await buy(product) }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                    .fontDesign(.serif)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.yellow)
                                
                                Text(product.displayPrice)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.white)
                            }
                            .padding(.all, 18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.yellow]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 4
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        
                    }
                }
                VStack(spacing: 20) {
                    Button {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Terms of Use")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 18, weight: .heavy))
                            .underline(color: Color.white)
                    }
                    
                    Button {
                        Task {
                            await storeKitView.restorePurchases()
                   
                        }
                    } label: {
                        Text("Restore Purchases")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 24, weight: .bold))
                            .fontDesign(.serif)
                    }
                }
                .foregroundStyle(Color.white)
                .font(.system(size: 20, weight: .heavy))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
        .background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.init(hex: "#5dc6db"), location: 0.0),   // В начале
                    .init(color: Color.init(hex: "#1b84b4"), location: 0.4),  // На 30%
                    .init(color: Color.init(hex: "#42b3d3"), location: 0.4), // На 60%
                    .init(color: Color.init(hex: "#063970"), location: 1.0) // В конце
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.gray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 4
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 8)
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.easeOut(duration: 1)) {
                    DispatchQueue.main.async {
                        isXmarkButton = false
                        firstSignIn = true
                    }
                }
            } label: {
                Image(systemName: "xmark.seal.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
            }
            .padding(.trailing, 14)
            .padding(.top, 8)
        }
    }
    func buy(_ product: Product) async {
        do {
            if try await storeKitView.purchase(product) != nil {
                DispatchQueue.main.async {
                    isPurchased = true
                    isXmarkButton = false
                }
            }
        } catch {
            print("Failed to purchase product: \(error)")
        }
    }
}

//#Preview {
//    StoreKitBuyAdvertisement()
//}
