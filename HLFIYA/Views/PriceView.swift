//
//  PriceView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/29/22.
//

import SwiftUI

struct PriceView: View {
    private let priceOptions = AllPrices().getPriceOptions()

    @State private var initialPrices = Set([""])
    @State private var saveTapped = false

    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var noResultsFound: Bool
    @Binding var apiError: Bool

    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.dismiss) private var dismiss
    var filters: FiltersState

    var body: some View {
        NavigationStack {
            List {
                ForEach(priceOptions, id: \.self) { priceOption in
                    MultiPicker(
                        title: AllPrices().getFormattedPrice(from: priceOption),
                        isSelected: filters.prices.contains(priceOption)
                    ) {
                        togglePrice(priceOption)
                    }
                }
            }
            .foregroundStyle(.primary)
            .navigationTitle("Choose Prices")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset", action: reset)
                        .font(.headline)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    AsyncButton(action: save) {
                        Text("Save").font(.headline)
                    }
                }
            }
        }
        .tint(.fuchsia)
        .onAppear { initialPrices = filters.prices }
        .onDisappear {
            if !saveTapped {
                filters.prices = initialPrices
                updatePriceName()
            }
        }
    }

    private func togglePrice(_ priceOption: String) {
        if filters.prices.contains(priceOption) {
            filters.prices.remove(priceOption)
        } else {
            filters.prices.insert(priceOption)
        }

        if filters.prices.isEmpty {
            filters.prices = ["All Prices"]
        } else {
            filters.prices.remove("All Prices")
        }

        if filters.prices.count == priceOptions.count - 1 {
            filters.prices = ["All Prices"]
        }

        if priceOption == "All Prices" {
            filters.prices = ["All Prices"]
        }

        updatePriceName()
    }

    private func updatePriceName() {
        guard let first = filters.prices.first else { return }
        if filters.prices.count == 1 {
            filters.priceName = AllPrices().getFormattedPrice(from: first)
        } else {
            filters.priceName = AllPrices().getPriceNames(from: filters.prices)
        }
    }

    private func reset() {
        filters.prices = ["All Prices"]
        filters.priceName = "All Prices"
    }

    private func save() async {
        saveTapped = true
        dismiss()
        let fetchedBusinesses = await MainView.refreshBusinesses(
            customLatitude: filters.customLatitude,
            customLongitude: filters.customLongitude,
            locationViewModel: locationViewModel,
            customRadius: filters.customRadius,
            categories: filters.categories,
            prices: filters.prices,
            onlyGetOpenNow: filters.openNow
        )
        setState(fetchedBusinesses: fetchedBusinesses)
        Utils.writePricesFilterToCache(prices: filters.prices, priceName: filters.priceName)
    }

    private func setState(fetchedBusinesses: [Business]) {
        nearbyRestaurants = fetchedBusinesses
        remainingRestaurantsInList = fetchedBusinesses.count
        currentRestaurantIndex = 0
        showRefreshButton = true
        apiError = false
        noResultsFound = fetchedBusinesses.isEmpty
    }
}
