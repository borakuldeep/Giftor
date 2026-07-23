//
//  IAPManager.swift
//  Giftor
//
//  Created by Kuldeep Bora on 21.02.26.
//
import StoreKit
import Combine

enum UserTier: Int, Comparable {
    case free = 0
    case pro = 1

    static func < (lhs: UserTier, rhs: UserTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var stringValue: String {
        self == .free ? "free" : "pro"
    }
}

let userDefaults = UserDefaults.standard

let proUserProdId = "com.xb.giftor.user.pro"
let coffeeProdId = "com.xb.giftor.coffee"
let userTypeKey = "premiumUserType"

class IAPManager: ObservableObject {
    @Published var products: [Product] = []
    @Published private(set) var userPaidStatus: String = "free"

    init(preview: Bool = false) {
        if !preview {
            Task {
                await self.retrieveProducts()
            }
        }
    }

    func retrieveProducts() async {
        do {
            let productIDs = [coffeeProdId, proUserProdId]
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
}

extension IAPManager {
    @MainActor
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify transaction
                let transaction = try self.verifyPurchase(verification)
                await transaction.finish()
                
                let newTier: UserTier = product.id == proUserProdId ? .pro : .free
                
                // Only upgrade if new tier is higher than current
                let currentTierRaw = userDefaults.integer(forKey: userTypeKey)
                let currentTier = UserTier(rawValue: currentTierRaw) ?? .free
                
                if newTier > currentTier {
                    userDefaults.setValue(newTier.rawValue, forKey: userTypeKey)
                    userPaidStatus = newTier.stringValue
                }
                
                return true
                
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }

    private func verifyPurchase(_ verification: VerificationResult<Transaction>)
        throws -> Transaction
    {
        switch verification {
        case .unverified:
            throw NSError(domain: "Verification failed", code: 1, userInfo: nil)
        case .verified(let transaction):
            return transaction
        }
    }
    
    @MainActor
    func restorePurchases() async {
        var highestTier: UserTier = .free
        var didRestoreWork = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == proUserProdId {
                highestTier = .pro
                didRestoreWork = true
            }
        }

        // Update app state
        userDefaults.setValue(highestTier.stringValue, forKey: userTypeKey)
        userPaidStatus = highestTier.stringValue

        if didRestoreWork {
            print("Purchase restored: \(highestTier.stringValue)")
        } else {
            print("No purchases to restore")
        }
    }
}
