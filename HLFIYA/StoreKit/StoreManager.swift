//
//  StoreManager.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import StoreKit

typealias Transaction = StoreKit.Transaction

public enum StoreError: Error {
    case failedVerification
}

@Observable
class StoreManager {
    private(set) var products: [Product] = []
    private(set) var purchasedIds: Set<String> = []

    @ObservationIgnored nonisolated(unsafe) private var updateListenerTask: Task<Void, Error>?

    init() {
        // Start a transaction listener as close to app launch as possible so we don't miss any transactions.
        updateListenerTask = listenForTransactions()

        Task { [weak self] in
            await self?.fetchProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func fetchProducts() async {
        do {
            let products = try await Product.products(for: ["nonconsumable.removeAds"])
            self.products = products

            for product in products where product.id == "nonconsumable.removeAds" {
                await isPurchased(product: product)
            }
        } catch {
            print(error)
        }
    }

    func isPurchased(product: Product) async {
        guard let state = await product.currentEntitlement else { return }

        switch state {
        case .verified(let transaction):
            purchasedIds.insert(transaction.productID)
        case .unverified:
            print("Unverified transaction")
        }
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

    nonisolated static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    func updatePurchasedIdentifiers(_ transaction: Transaction) {
        if transaction.revocationDate == nil {
            purchasedIds.insert(transaction.productID)
        } else {
            purchasedIds.remove(transaction.productID)
        }
    }

    func listenForTransactions() -> Task<Void, Error> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try Self.checkVerified(result)
                    self.updatePurchasedIdentifiers(transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
}
