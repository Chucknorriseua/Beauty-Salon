//
//  SheetStoreKitProductSelect.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 06/11/2024.
//

import SwiftUI
import StoreKit

struct SheetStoreKitProductSelect: View {
    
    @EnvironmentObject var storeKitView: StoreViewModel
    @Environment(\.dismiss) var dismiss
    @State var isPurchased: Bool = false
    @State private var isBuyMaster: Bool = false
    @State private var isBuyAdmin: Bool = false
    @State private var isShowSubscribe: Bool = true
    @State private var isSelectedRole: Bool = false
    @State private var isShowPolicy: Bool = false
    @State private var loadText: String = "Restore purchase"
    @AppStorage("useRole") var useRole: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    if storeKitView.useRole == "" || isSelectedRole {
                        VStack {
                            VStack {
                                Text("Purchase a subscription to create your salon as an administrator, or purchase a master subscription to work in an existing salon. Please note: the Admin subscription is only available for salon owners and the Master subscription is only available for masters. You can only have one active subscription.")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 22, weight: .heavy))
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.top, 60)
                            .padding(.horizontal, 10)
                            VStack {
                                VStack(spacing: 20) {
                                    Button {
                                        withAnimation(.snappy(duration: 1)) {
                                            storeKitView.useRole = "Admin"
                                            isSelectedRole.toggle()
                                            Task { await storeKitView.requestProduct() }
                                        }
                                    } label: {
                                        Text("Buy an admin subscription to manage your salon")
                                            .foregroundStyle(Color.white)
                                            .font(.system(size: 20, weight: .heavy))
                                            .padding(.all, 14)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.11, green: 0.14, blue: 0.12))
                                    .clipShape(.rect(cornerRadius: 14))
//                                    .disabled(storeKitView.useRole != "Admin")
//                                    .opacity(storeKitView.useRole != "Admin" ? 0.5 : 1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.gray, .white]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .clipShape(.rect(cornerRadius: 14))
                                    
                                    Button {
                                        withAnimation(.snappy(duration: 1)) {
                                            storeKitView.useRole = "Master"
                                            isSelectedRole.toggle()
                                            Task { await storeKitView.requestProduct() }
                                        }
                                    } label: {
                                        Text("Buy a master subscription to create your profile")
                                            .foregroundStyle(Color.white)
                                            .font(.system(size: 20, weight: .heavy))
                                            .padding(.all, 14)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.11, green: 0.14, blue: 0.12))
                                    .clipShape(.rect(cornerRadius: 14))
//                                    .disabled(storeKitView.useRole != "Master")
//                                    .opacity(storeKitView.useRole != "Master" ? 0.5 : 1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.gray, .white]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .clipShape(.rect(cornerRadius: 14))
                                    VStack(spacing: 20) {
                                        Button {
                                            isShowPolicy = true
                                        } label: {
                                            HStack {
                                                Text("Privacy Policy and Terms of Use")
                                                Image(systemName: "rectangle.filled.and.hand.point.up.left")
                                                
                                            }
                                            .foregroundStyle(Color.white)
                                            .font(.system(size: 18, weight: .bold))
                                        }
                                        .padding(.top, 20)
                                        Spacer()
                                        Button {
                                            Task {
                                                await storeKitView.restorePurchases()
                                                dismiss()
                                            }
                                        } label: {
                                            Text("Restore Purchases")
                                                .foregroundStyle(Color.white)
                                                .font(.system(size: 24, weight: .bold))
                                                .fontDesign(.serif)
                                        }
                                    }
                                    
                             
                                }
                                .padding(.horizontal, 10)
                                
                            }
                        }

                    } else {
                        VStack {
                            HStack {
                                Button {
                                    withAnimation(.snappy(duration: 1)) {
                                        isSelectedRole.toggle()
                                    }
                                } label: {
                                    Image(systemName: "chevron.backward")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.white)
                                }
                                Spacer()
                                Text("\(storeKitView.useRole)")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundStyle(Color.yellow)
                            }
                            .frame(height: 40)
                            .padding(.horizontal, 10)
                            VStack {
                                Text(storeKitView.useRole == "Admin" ?
                                    "You are purchasing an admin subscription to fully manage your salon, masters, and client appointments. This will give you access to features for setting up your salon profile, managing master schedules, and tracking client bookings." :
                                    (storeKitView.useRole == "Master" ?
                                        "You are purchasing a master subscription to receive bookings from the admin and clients, manage your schedule, and increase service visibility. Independent masters can work from home or offer mobile services." : ""))
                                .font(.system(size: 20, weight: .heavy))
                                    .fontDesign(.serif)
                                    .foregroundStyle(Color.white)
                                    .padding(.bottom, 10)
                                    .multilineTextAlignment(.leading)
                                
                                ForEach(storeKitView.useRole == "Admin" ? storeKitView.subscriptionsAdmin : storeKitView.subscriptionsMaster) { product in
                                    VStack(spacing: 24) {
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
                                                
                                            }
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
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                    }
                                    .background(.ultraThinMaterial.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.yellow, .mint]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 4
                                            )
                                    )
                                    .clipShape(.rect(cornerRadius: 16))
                                    
                                }

                            }
                            .padding(.horizontal, 6)
                            VStack(spacing: 16) {
                                Text("7-day free trial, then will be Automatically renew unless canceled at least 24 hours before the end of the trial or billing period.")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 18, weight: .heavy))
                                
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
                                Spacer()
                                
                                Button {
                                    Task {
                                        await storeKitView.restorePurchases()
                                        dismiss()
                                    }
                                } label: {
                                    Text("Restore Purchases")
                                        .foregroundStyle(Color.white)
                                        .font(.system(size: 24, weight: .bold))
                                        .fontDesign(.serif)
                                }
                                
                            }
                            .padding(.top, 14)
                            .padding(.horizontal, 6)
                   
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.top, 10)
    
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                    storeKitView.useRole = useRole
                    Task {
                        await storeKitView.requestProduct()
                    }
                }
   
        }
        .createBackgrounfFon()
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $isShowPolicy, content: {
            SheetPrivacyPolicy()
                .presentationDetents([.height(300)])
        })
        .overlay(alignment: .center) { CustomLoader(isLoader: $storeKitView.isLoadRestore, text: $loadText) }
        .ignoresSafeArea(.keyboard)
        
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

