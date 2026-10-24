//
//  PriceSelection.swift
//  HLFIYA
//

import Foundation

/// An editable set of selected price levels, enforcing the "All Prices" rules.
nonisolated struct PriceSelection: Equatable {
    private(set) var prices: Set<String>

    init(prices: Set<String> = [AllPrices.allPrices]) {
        self.prices = prices.isEmpty ? [AllPrices.allPrices] : prices
    }

    /// Whether a price option is selected; setting it applies the selection rules.
    subscript(isSelected price: String) -> Bool {
        get { prices.contains(price) }
        set {
            guard newValue != prices.contains(price) else { return }
            toggle(price)
        }
    }

    /// The user-facing summary, such as "All Prices" or "$, $$".
    var summary: String {
        AllPrices.summary(for: prices)
    }

    /// The comma-separated price levels the Yelp API expects.
    var apiValue: String {
        prices == [AllPrices.allPrices] ? "1,2,3,4" : prices.sorted().joined(separator: ",")
    }

    mutating func toggle(_ price: String) {
        if prices.contains(price) {
            prices.remove(price)
        } else {
            prices.insert(price)
        }

        if price == AllPrices.allPrices || prices.isEmpty {
            prices = [AllPrices.allPrices]
        } else {
            prices.remove(AllPrices.allPrices)
            // Selecting every specific price level is the same as "All Prices".
            if prices.count == AllPrices.priceOptions.count - 1 {
                prices = [AllPrices.allPrices]
            }
        }
    }

    mutating func reset() {
        prices = [AllPrices.allPrices]
    }
}
