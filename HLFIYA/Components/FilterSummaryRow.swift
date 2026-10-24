//
//  FilterSummaryRow.swift
//  HLFIYA
//

import SwiftUI

/// One "Label: value" line in the filter summary.
struct FilterSummaryRow: View {
    let label: LocalizedStringResource
    let value: String

    var body: some View {
        let labelText = Text("\(Text(label)):").foregroundStyle(.secondary)
        let valueText = Text(value).bold()

        Text("\(labelText) \(valueText)")
            .lineLimit(2)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    FilterSummaryRow(label: "Categories", value: "Pizza and 2 More")
}
