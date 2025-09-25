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
class StoreManager: @unchecked Sendable {
    private(set) var products: [Product]
    private(set) var purchasedIds = Set<String>()

    var updateListenerTask: Task<Void, Error>? = nil

    init() {
        products = []
        purchasedIds = []

        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()

        Task { @MainActor [weak self] in
            //Initialize the store by starting a product request.
            await self?.fetchProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    @MainActor
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: ["nonconsumable.removeAds"])
            self.products = products

            for product in products {
                if product.id == "nonconsumable.removeAds" {
                    await isPurchased(product: product)
                }
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
        case .unverified(_, _):
            print("Unverified transaction")
        }
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Deliver content to the user
            await updatePurchasedIdentifiers(transaction)

            // Always finish a transaction
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            print("user cancelled transaction")
            return nil
        @unknown default:
            print("unknown issue")
            return nil
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        print("checking verified")
        //Check if the transaction passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
            print("failed verification")
            throw StoreError.failedVerification
        case .verified(let safe):
            //If the transaction is verified, unwrap and return it.
            print("verified")
            return safe
        }
    }

    @MainActor
    func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        print("updating purchased IDs")
        if transaction.revocationDate == nil {
            //If the App Store has not revoked the transaction, add it to the list of `purchasedIdentifiers`.
            self.purchasedIds.insert(transaction.productID)
        } else {
            //If the App Store has revoked this transaction, remove it from the list of `purchasedIdentifiers`.
            self.purchasedIds.remove(transaction.productID)
        }
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { @Sendable [weak self] in
            //Iterate through any transactions which didn't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver content to the user.
                    await self.updatePurchasedIdentifiers(transaction)

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a receipt it can read but it failed verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
}
