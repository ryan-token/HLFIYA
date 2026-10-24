//
//  AllPrices.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/29/22.
//

import Foundation

/// The Yelp price levels the app offers as filters.
nonisolated enum AllPrices {
    /// The option that means "every price level".
    static let allPrices = "All Prices"

    /// Every selectable price option, in the order they appear in the picker.
    static let priceOptions = [allPrices, "1", "2", "3", "4"]

    /// Returns the user-facing name for a price option, such as "$$" for "2".
    static func displayName(for price: String) -> String {
        switch price {
        case allPrices: allPrices
        case "1": "$"
        case "2": "$$"
        case "3": "$$$"
        case "4": "$$$$"
        default: "Unknown"
        }
    }

    /// Returns a summary of the selected price options, such as "$, $$$".
    static func summary(for prices: Set<String>) -> String {
        prices.map(displayName(for:)).sorted().formatted(.list(type: .and, width: .narrow))
    }
}
