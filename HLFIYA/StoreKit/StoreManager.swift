//
//  StoreManager.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import StoreKit

typealias Transaction = StoreKit.Transaction

enum StoreError: Error {
    case failedVerification
}

@MainActor
@Observable
final class StoreManager {
    static let removeAdsProductID = "nonconsumable.removeAds"

    private static let cachedPurchasedIdsKey = "StoreManager.cachedPurchasedIds"

    private(set) var products: [Product] = []
    // Seeded synchronously from UserDefaults so the UI starts in the correct state on cold
    // launch and doesn't shift when `refreshEntitlements()` finishes.
    private(set) var purchasedIds: Set<String>

    @ObservationIgnored private var updateListenerTask: Task<Void, Never>?

    init() {
        let cached = UserDefaults.standard.stringArray(forKey: Self.cachedPurchasedIdsKey) ?? []
        purchasedIds = Set(cached)

        // Start the transaction listener as close to launch as possible so we don't miss any
        // transactions that occur outside the app or on other devices.
        updateListenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(transactionResult: result)
            }
        }

        Task { [weak self] in await self?.fetchProducts() }
        Task { [weak self] in await self?.refreshEntitlements() }
    }

    isolated deinit {
        updateListenerTask?.cancel()
    }

    func fetchProducts() async {
        do {
            products = try await Product.products(for: [Self.removeAdsProductID])
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    /// Rebuilds `purchasedIds` from the customer's current entitlements.
    func refreshEntitlements() async {
        var ids: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result, transaction.revocationDate == nil else {
                continue
            }
            ids.insert(transaction.productID)
        }
        purchasedIds = ids
        persistPurchasedIds()
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try Self.checkVerified(verification)
            updatePurchasedIdentifiers(transaction)
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    /// Asks the App Store to re-sync signed transactions, the StoreKit 2 equivalent of
    /// "Restore Purchases".
    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    nonisolated static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func handle(transactionResult: VerificationResult<Transaction>) async {
        do {
            let transaction = try Self.checkVerified(transactionResult)
            updatePurchasedIdentifiers(transaction)
            await transaction.finish()
        } catch {
            print("Transaction failed verification: \(error)")
        }
    }

    private func updatePurchasedIdentifiers(_ transaction: Transaction) {
        if transaction.revocationDate == nil {
            purchasedIds.insert(transaction.productID)
        } else {
            purchasedIds.remove(transaction.productID)
        }
        persistPurchasedIds()
    }

    private func persistPurchasedIds() {
        UserDefaults.standard.set(Array(purchasedIds), forKey: Self.cachedPurchasedIdsKey)
    }
}
