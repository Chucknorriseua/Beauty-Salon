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
    
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionsGroupStatus: RenewalState?
    
    private let productIds: [String] = ["subscription.yearly", "subscription.monthly"]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    @AppStorage ("hasActiveSubscribe") private(set) var hasActiveSubscribe: Bool = false
    
    var checkSubscribe: Bool {
        Task {await updateCustomerProductStatus()} 
        return hasActiveSubscribe
//        && !purchasedSubscriptions.isEmpty
    }
    
    init() {
        
        updateListenerTask = listenerForTransaction()
        
        Task {
            await requestProduct()
            
            await updateCustomerProductStatus()
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
    func requestProduct() async  {
        do {
            subscriptions = try await Product.products(for: productIds)
            print(subscriptions)
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
        
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transition = try checkVerified(result)
                switch transition.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: {$0.id == transition.productID}) {
                        purchasedSubscriptions.append(subscription)
                        hasActive = true
                    }
                default:
                    break
                }
                
                await transition.finish()
            } catch {
                print("Failed updating product")
            }
        }
        hasActiveSubscribe = hasActive
    }
}
