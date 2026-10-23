//
//  FilterToolbarItems.swift
//  HLFIYA
//

import SwiftUI

/// The category, price, and location filter buttons in the main screen's bottom bar.
struct FilterToolbarItems: ToolbarContent {
    @Binding var activeSheet: MainSheet?

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button("Categories", systemImage: "line.3.horizontal.decrease.circle") {
                activeSheet = .categories
            }
            .tint(.pink)

            Button("Price", systemImage: "dollarsign.circle") {
                activeSheet = .prices
            }
            .tint(.green)

            Button("Location", systemImage: "map.circle") {
                activeSheet = .location
            }
            .tint(.blue)
        }
    }
}
