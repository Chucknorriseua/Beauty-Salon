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
 
    @Environment (\.dismiss) var dimsiss
    @State var isPurchased: Bool = false
    
    var body: some View {
        Group {
            Section {
                VStack {
                    Text("Purchase a subscription to create your salon or create a profile as a master.")
                        .foregroundStyle(Color.yellow.opacity(0.8))
                        .font(.system(size: 22, weight: .bold))
                }
                ForEach(storeKitView.subscriptions) { product in
                    Button {
                        Task { await buy(product)
                            dimsiss()
                        }
                    } label: {
                        VStack {
                            HStack {
                                Text(product.displayPrice)
                                Text(product.displayName)
                            }.font(.system(size: 18, weight: .bold))
                            
                            Text(product.description)
                                .font(.system(size: 16))
                                    .foregroundStyle(Color.white)
                                    .opacity(0.8)
                                
                        }.padding()
                    }.frame(width: 200, height: 40)
                }
                .foregroundStyle(Color.white)
                .font(.system(size: 16, weight: .bold))
                .padding()
                .background(Color.blue.opacity(0.8))
                .clipShape(.rect(cornerRadius: 16))
                
            }
        }.createBackgrounfFon()

    }
                            
    func buy(_ product: Product) async {
        do {
            if try await storeKitView.purchase(product) != nil {
                isPurchased = true
            }
        } catch {
            print("failed Purchased")
    }
  }
}
