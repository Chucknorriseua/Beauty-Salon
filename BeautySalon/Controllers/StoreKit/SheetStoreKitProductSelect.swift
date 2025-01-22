//
//  SheetStoreKitProductSelect.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 06/11/2024.
//

import SwiftUI
import StoreKit

struct SheetStoreKitProductSelect: View {
    @StateObject var storeKitView = StoreViewModel()
    @Environment(\.dismiss) var dismiss
    @State var isPurchased: Bool = false
    @State private var isBuyMaster: Bool = false
    @State private var isBuyAdmin: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                Text("Purchase a subscription to create your salon or create a profile as a master.")
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .lineLimit(6)
                    .foregroundStyle(Color.yellow.opacity(0.8))
                    .font(.system(size: 22, weight: .bold))
                    .padding(.bottom, 20)
                
                if storeKitView.useRole == "" {
                    VStack {
                        Button {
                            withAnimation(.snappy(duration: 1)) {
                                
                                storeKitView.useRole = "Admin"
                                Task { await storeKitView.requestProduct(role: "Admin") }
                            }
                        } label: {
                            Text("Buy subscription Admin")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 16, weight: .bold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(20)
                        }
                        Button {
                            withAnimation(.snappy(duration: 1)) {
                                
                                storeKitView.useRole = "Master"
                                Task { await storeKitView.requestProduct(role: "Master") }
                            }
                        } label: {
                            Text("Buy subscription Master")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 16, weight: .bold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(20)
                        }
                        Spacer()
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

                    }.padding(.horizontal, 20)
                } else {
                    LazyVStack {
                        ForEach(storeKitView.useRole == "Admin" ? storeKitView.subscriptionsAdmin : storeKitView.subscriptionsMaster) { product in
                            VStack {
                                HStack {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(product.displayName)
                                            .fontDesign(.serif)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.yellow)
                                        Text(product.displayPrice)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.green)
                                        Text(product.description)
                                            .foregroundStyle(Color.white)
                                            .font(.system(size: 16, weight: .black))
                                    }.padding(.top, 8)
                                    Spacer()
                                    Button {
                                        Task { await buy(product) }
                                    } label: {
                                        Text("Buy")
                                            .foregroundStyle(Color.white)
                                            .fontWeight(.bold)
                                            .padding(.all, 14)
                                            .background(Color.blue)
                                            .clipShape(.rect(cornerRadius: 22))
                                    }
                                }.padding(.horizontal, 8)
                                    .padding(.vertical, 14)
                            }
                            .background(.ultraThinMaterial.opacity(0.8))
                            .clipShape(.rect(cornerRadius: 16))
                            
                        }
                        
                    }.padding(.horizontal, 8)
                    CustomButton(title: "Back") {
                        withAnimation(.snappy(duration: 1)) {
                            storeKitView.useRole = ""
                        }
                    }
                }
                Spacer()
            }.padding(.top, 18)
        }.background(Color.init(hex: "#3e5b47").opacity(0.8))
        
    }
    func buy(_ product: Product) async {
        do {
            if try await storeKitView.purchase(product) != nil {
                isPurchased = true
                dismiss()
            }
        } catch {
            print("Failed to purchase product: \(error)")
        }
    }
}

#Preview {
    SheetStoreKitProductSelect()
}

