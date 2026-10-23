//
//  PriceView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/29/22.
//

import SwiftUI

/// Chooses which price levels to search for.
///
/// Edits a draft; nothing changes until Save, so swiping the sheet away cancels.
struct PriceView: View {
    let feed: RestaurantFeed
    let filters: FiltersState

    @State private var selection = PriceSelection()

    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(AllPrices.priceOptions, id: \.self) { price in
                    Toggle(AllPrices.displayName(for: price), isOn: $selection[isSelected: price])
                }
                .toggleStyle(.checkmark)
            }
            .navigationTitle("Choose Prices")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset", systemImage: "arrow.counterclockwise") {
                        selection.reset()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: save)
                }
            }
        }
        .tint(.fuchsia)
        .onAppear {
            selection = filters.prices
        }
    }

    private func save() {
        filters.applyPrices(selection)
        feed.reload(filters: filters, currentLocation: locationViewModel.location)
        dismiss()
    }
}

#Preview {
    PriceView(feed: RestaurantFeed(), filters: FiltersState())
        .environment(LocationViewModel())
}
