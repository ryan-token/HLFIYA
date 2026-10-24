//
//  RestaurantSummarySection.swift
//  HLFIYA
//

import SwiftUI

/// The rating, price, and categories at the top of a restaurant's details.
struct RestaurantSummarySection: View {
    let rating: Double
    let reviewCount: Int?
    let price: String
    let categories: [String]

    var body: some View {
        VStack(alignment: .leading) {
            StarRatingView(rating: rating, label: "Rating:", reviewCount: reviewCount)
            DollarView(price: price, label: "Price:")

            if !categories.isEmpty {
                // Separate strings, so each language can phrase the singular and plural.
                Group {
                    if categories.count == 1 {
                        Text("Category: \(categories.formatted())")
                    } else {
                        Text("Categories: \(categories.formatted())")
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    List {
        RestaurantSummarySection(
            rating: 4.5,
            reviewCount: 6352,
            price: "$$",
            categories: ["Seafood", "Seafood Markets"]
        )
    }
}
