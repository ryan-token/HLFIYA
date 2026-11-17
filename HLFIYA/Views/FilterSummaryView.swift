//
//  FilterSummaryView.swift
//  HLFIYA
//

import SwiftUI

/// A short summary of the active category, price, and location filters.
///
/// One labeled row per filter when there's room, or the three values on one line when
/// there isn't, such as at large text sizes on a short window.
struct FilterSummaryView: View {
    let filters: FiltersState

    var body: some View {
        let radius = "Within \(filters.radius.formatted(.number.precision(.fractionLength(1)))) Miles"

        ViewThatFits(in: .vertical) {
            VStack {
                FilterSummaryRow(label: "Categories", value: filters.categories.summary)
                FilterSummaryRow(label: "Prices", value: filters.prices.summary)
                FilterSummaryRow(label: "Location", value: radius)
            }
            .padding(.vertical)

            Text([filters.categories.summary, filters.prices.summary, radius].joined(separator: " · "))
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.vertical)
                // The labels don't fit on screen, but VoiceOver still says what each value is.
                .accessibilityLabel(
                    "Categories: \(filters.categories.summary), Prices: \(filters.prices.summary), Location: \(radius)"
                )
        }
    }
}

#Preview {
    FilterSummaryView(filters: FiltersState())
}
