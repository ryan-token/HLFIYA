//
//  CardSummary.swift
//  HLFIYA
//

import Foundation

/// The restaurant details printed on a card's footer.
nonisolated struct CardSummary: Equatable {
    var name: String
    var rating: Double
    /// The Yelp price string, such as "$$".
    var price: String
    var category: String
}

nonisolated extension CardSummary {
    init(business: Business) {
        self.init(
            name: business.name ?? "",
            rating: business.rating ?? 0,
            price: business.price ?? "",
            category: business.categories?.first?.title ?? ""
        )
    }

    /// The card's details as one sentence for VoiceOver, such as
    /// "Jake's Brew Bar, 4.5 stars, 2 dollar signs, and Beer Gardens".
    var accessibilityDescription: String {
        let rating = rating.formatted(.number.precision(.fractionLength(1)))
        return [name, "\(rating) stars", "\(price.count) dollar signs", category]
            .filter { !$0.isEmpty }
            .formatted(.list(type: .and, width: .narrow))
    }
}
