//
//  FilterSummaryView.swift
//  HLFIYA
//

import SwiftUI

/// A short summary of the active category, price, and location filters.
struct FilterSummaryView: View {
    let filters: FiltersState

    var body: some View {
        VStack {
            FilterSummaryRow(label: "Categories", value: filters.categories.summary)
            FilterSummaryRow(label: "Prices", value: filters.prices.summary)
            FilterSummaryRow(
                label: "Location",
                value: "Within \(filters.radius.formatted(.number.precision(.fractionLength(1)))) Miles"
            )
        }
        .padding(.vertical)
    }
}

#Preview {
    FilterSummaryView(filters: FiltersState())
}
