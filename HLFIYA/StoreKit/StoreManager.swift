//
//  StoreManager.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI
import StoreKit

class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedIds: [String] = []
    
    func fetchProducts() {
        Task {
            do {
                let products = try await Product.products(for: ["nonconsumable.removeAds"])
                DispatchQueue.main.async {
                    self.products = products
                }
                
                if let product = products.first {
                    await isPurchased(product: product)
                }
                print(products)
            } catch {
                print(error)
            }
        }
    }
    
    func isPurchased(product: Product) async {
        guard let state = await product.currentEntitlement else { return }
        switch state {
        case .verified(let transaction):
            print(transaction.productID)
            DispatchQueue.main.async {
                self.purchasedIds.append(transaction.productID)
            }
        case .unverified(_, _):
            print("Another unverified transaction")
        }
    }
    
    func purchase() {
        Task {
            guard let product = products.first else { return }
            
            do {
                let result = try await product.purchase()
                
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        DispatchQueue.main.async {
                            self.purchasedIds.append(transaction.productID)
                        }
                    case .unverified(_, _):
                        print("unverified transaction")
                    }
                case .userCancelled:
                    print("user cancelled transaction")
                case .pending:
                    print("pending user verification")
                @unknown default:
                    print("unknown issue")
                }
            } catch {
                print(error)
            }
        }
    }
}
