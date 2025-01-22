//
//  StoreViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/11/2024.
//

import SwiftUI
import StoreKit

enum StoreError: Error {
    case FailedVerification
}

typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

@MainActor
final class StoreViewModel: ObservableObject {
    
    static var shared = StoreViewModel()
    
    @AppStorage ("useRole") var useRole: String = ""
  
    @Published private(set) var subscriptionsMaster: [Product] = []
    @Published private(set) var subscriptionsAdmin: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionsGroupStatus: RenewalState?
    
    let masterProductIds: [String] = ["master.subscription.yearly", "master.subscription.monthly"]
    let adminProductIds: [String] = ["admin.subscription.yearly", "admin.subscription.monthly"]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    @AppStorage ("hasActiveSubscribe") var hasActiveSubscribe: Bool = false
    
    var checkSubscribe: Bool {
        Task {
            await updateCustomerProductStatus()
        }
        return hasActiveSubscribe
    }
    
    init() {
        
        updateListenerTask = listenerForTransaction()
        
        Task {
            await requestProduct(role: useRole)
//            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    
    func listenerForTransaction() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func restorePurchases() async {
        do {
            for await result in StoreKit.Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                await transaction.finish()
            }
            await updateCustomerProductStatus()
        } catch {
            print("Failed to restore purchases: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func requestProduct(role: String) async  {
        do {
            if role == "Admin" {
                subscriptionsAdmin = try await Product.products(for: adminProductIds)
                print(subscriptionsAdmin)
            } else if role == "Master" {
                subscriptionsMaster = try await Product.products(for: masterProductIds)
                print(subscriptionsMaster)
            }
        } catch {
            print("Failed product request from app store server", error.localizedDescription)
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let results = try await product.purchase()
        
        switch results {
        case .success(let verification):
            let transaction = try checkVerified(verification)
        
            await updateCustomerProductStatus()
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    
    func checkVerified<T>(_ results: VerificationResult<T>) throws -> T {
        switch results {
            
        case .unverified:
            throw StoreError.FailedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var hasActive = false
        purchasedSubscriptions.removeAll()

        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptionsMaster.first(where: { $0.id == transaction.productID }) {
                        if !purchasedSubscriptions.contains(where: { $0.id == subscription.id }) {
                            purchasedSubscriptions.append(subscription)
                        }
                        hasActive = true
                    } else if let subscription = subscriptionsAdmin.first(where: { $0.id == transaction.productID }) {
                        if !purchasedSubscriptions.contains(where: { $0.id == subscription.id }) {
                            purchasedSubscriptions.append(subscription)
                        }
                        hasActive = true
                    }

                default:
                    break
                }

                await transaction.finish()
            } catch {
                print("Failed updating product status: \(error.localizedDescription)")
            }
        }

        hasActiveSubscribe = hasActive
    }
}
