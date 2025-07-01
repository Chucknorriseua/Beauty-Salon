//
//  StoreViewModel.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/11/2024.
//

import SwiftUI
import StoreKit
import FirebaseAuth
import FirebaseFirestore

enum StoreError: Error {
    case FailedVerification
}

typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

@MainActor
final class StoreViewModel: ObservableObject {
    
    static var shared = StoreViewModel()
    
    @AppStorage("useRole") var useRole: String = ""
  
    @Published private(set) var subscriptionsMaster: [Product] = []
    @Published private(set) var subscriptionsAdmin: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionsGroupStatus: RenewalState?
    @Published var isLoadRestore: Bool = false
    @Published var isBuySubscribe: Bool = false
    
    let masterProductIds: [String] = ["masters.subscription.yearly2999", "master.subscription.monthly.299"]
    let adminProductIds: [String] = ["admin.subscriptions.yearly3999", "admin.subscription.monthly399"]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    @AppStorage("hasActiveSubscribe") var hasActiveSubscribe: Bool = false {
        didSet {
            print("hasActiveSubscribe changed to", hasActiveSubscribe)
        }
    }
  
    
    var checkSubscribe: Bool {
        return hasActiveSubscribe
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
    
    @MainActor
    func listenerForTransaction() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    print("Возврат средств для Product ID: \(transaction.productID)")
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
        isLoadRestore = true
        defer { isLoadRestore = false }
        do {
            // Запускаем процесс восстановления покупок
            try await AppStore.sync()
            
            // Проверяем текущие активные подписки
            var restoredProducts: [Product] = []
            
            for await result in StoreKit.Transaction.currentEntitlements {
                do {
                    let transaction = try checkVerified(result)
                    if let product = (subscriptionsMaster + subscriptionsAdmin).first(where: { $0.id == transaction.productID }) {
                        restoredProducts.append(product)
                    }
                    
                    await transaction.finish() // Завершаем транзакцию
                } catch {
                    print("Ошибка валидации транзакции: \(error)")
                }
            }
            
            // Обновляем список купленных подписок
            purchasedSubscriptions = restoredProducts
            hasActiveSubscribe = !restoredProducts.isEmpty
            await updateCustomerProductStatus()
            
            print("Покупки восстановлены: \(restoredProducts.map { $0.id })")
        } catch {
            print("Ошибка восстановления покупок: \(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func requestProduct() async  {
     
        do {
            subscriptionsAdmin = try await Product.products(for: adminProductIds)
            print("Admin subscriptions",subscriptionsAdmin)
//            if useRole == "Admin" {
//                subscriptionsAdmin = try await Product.products(for: adminProductIds)
//                print("Admin subscriptions",subscriptionsAdmin)
//            } else if useRole == "Master" {
//                subscriptionsMaster = try await Product.products(for: masterProductIds)
//                print("Master subscriptions",subscriptionsMaster)
//            }
            await updateCustomerProductStatus()
        } catch {
            print("Failed product request from app store server", error.localizedDescription)
        }
       
    }
    
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let results = try await product.purchase()
        
        switch results {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            let price = product.price
            let currency = product.priceFormatStyle.currencyCode
         
            await updateCustomerProductStatus()
            saveTransactionToFirestore(transaction: transaction, price: price, currency: currency)
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
//        print("updateCustomerProductStatus-------------------")
 
        var hasActive = false
        purchasedSubscriptions.removeAll()

//        print("Start checking subscriptions...")

        for await result in StoreKit.Transaction.currentEntitlements {
//            print("Checking subscription...")
            do {
                let transaction = try checkVerified(result)
//                print("Verified transaction: \(transaction.productID)")

                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptionsMaster.first(where: { $0.id == transaction.productID }) {
                        if !purchasedSubscriptions.contains(where: { $0.id == subscription.id }) {
                            purchasedSubscriptions.append(subscription)
                        }
                        DispatchQueue.main.async {
                            hasActive = true
                        }
//                        print("Active subscription found in master: \(subscription.id)")
                    } else if let subscription = subscriptionsAdmin.first(where: { $0.id == transaction.productID }) {
                        if !purchasedSubscriptions.contains(where: { $0.id == subscription.id }) {
                            purchasedSubscriptions.append(subscription)
                        }
                        DispatchQueue.main.async {
                            hasActive = true
                        }
//                        print("Active subscription found in admin: \(subscription.id)")
                    }

                default:
                    break
                }

                await transaction.finish()
            } catch {
                print("Failed updating product status: \(error.localizedDescription)")
            }
        }
//
//        // Логируем изменения состояния
//        print("Active subscriptions after checking:", purchasedSubscriptions.map { $0.id })
//        print("Has active subscription:", hasActive)
//
//        // Обновляем состояние подписки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hasActiveSubscribe = hasActive
        }

//        if !hasActive {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                if self.useRole == "Admin" || self.useRole == "Master" {
//                    coordinator.popToRoot()
//                }
//            }
//        }
    }
    
    func saveTransactionToFirestore(transaction: StoreKit.Transaction, price: Decimal, currency: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let transactionData: [String: Any] = [
            "userID": userID,
            "productID": transaction.productID,
            "transactionID": String(transaction.id),
            "purchaseDate": transaction.purchaseDate,
            "price": price.description,
            "currency": currency,
            "status": transaction.revocationDate == nil ? "active" : "refunded"
        ]
        
        db.collection("Transactions").document(String(transaction.id)).setData(transactionData) { error in
            if let error = error {
                print("Ошибка при сохранении транзакции: \(error.localizedDescription)")
            } else {
                print("Транзакция успешно сохранена в Firestore")
            }
        }
    }
}

