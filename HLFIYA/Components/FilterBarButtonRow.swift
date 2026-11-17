//
//  FilterBarButtonRow.swift
//  HLFIYA
//

import SwiftUI

/// The category, price, and location buttons side by side, with or without their titles.
struct FilterBarButtonRow: View {
    let showsTitles: Bool
    @Binding var activeSheet: MainSheet?

    var body: some View {
        HStack(alignment: .top) {
            FilterBarButton(
                title: "Categories",
                systemImage: "line.3.horizontal.decrease",
                tint: .pink,
                sheet: .categories,
                showsTitle: showsTitles,
                activeSheet: $activeSheet
            )

            FilterBarButton(
                title: "Price",
                systemImage: "dollarsign",
                tint: .green,
                sheet: .prices,
                showsTitle: showsTitles,
                activeSheet: $activeSheet
            )

            FilterBarButton(
                title: "Location",
                systemImage: "map",
                tint: .blue,
                sheet: .location,
                showsTitle: showsTitles,
                activeSheet: $activeSheet
            )
        }
    }
}

#Preview {
    VStack {
        FilterBarButtonRow(showsTitles: true, activeSheet: .constant(nil))
        FilterBarButtonRow(showsTitles: false, activeSheet: .constant(nil))
    }
}
