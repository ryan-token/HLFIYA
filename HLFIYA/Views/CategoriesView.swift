//
//  CategoriesView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import SwiftUI

struct CategoriesView: View {
    private let yelpCategories = AllCategories().getYelpCategories()

    @State private var onlyShowOpenNow = false
    @State private var initialOpenNowValue = false
    @State private var initialCategories = Set([""])
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
                Section {
                    Toggle("Currently Open", isOn: $onlyShowOpenNow)
                } header: {
                    Text("Hours").foregroundStyle(.gray)
                } footer: {
                    Text("Toggle on to only show places that are currently open. Toggle off to show all places.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Section {
                    ForEach(yelpCategories, id: \.self) { yelpCategory in
                        MultiPicker(
                            title: AllCategories().getFormattedCategory(from: yelpCategory),
                            isSelected: filters.categories.contains(yelpCategory)
                        ) {
                            toggleCategory(yelpCategory)
                        }
                    }
                } header: {
                    Text("Types").foregroundStyle(.gray)
                }
            }
            .foregroundStyle(.primary)
            .navigationTitle("Choose Categories")
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
        .onAppear {
            onlyShowOpenNow = filters.openNow
            initialOpenNowValue = filters.openNow
            initialCategories = filters.categories
        }
        .onDisappear {
            if !saveTapped {
                onlyShowOpenNow = initialOpenNowValue
                filters.categories = initialCategories
                updateCategoriesNames()
            }
        }
    }

    private func toggleCategory(_ yelpCategory: String) {
        if filters.categories.contains(yelpCategory) {
            filters.categories.remove(yelpCategory)
        } else {
            filters.categories.insert(yelpCategory)
        }

        // Only allow 'All Food' to be selected if nothing else is selected
        if filters.categories.isEmpty {
            filters.categories = ["food"]
        } else {
            filters.categories.remove("food")
        }

        // Select 'All Food' if user manually selects all options
        if filters.categories.count == yelpCategories.count - 1 {
            filters.categories = ["food"]
        }

        // If user specifically selects 'All Food', deselect everything else
        if yelpCategory == "food" {
            filters.categories = ["food"]
        }

        updateCategoriesNames()
    }

    private func updateCategoriesNames() {
        guard let first = filters.categories.first else { return }
        if filters.categories.count == 1 {
            filters.categoriesNames = AllCategories().getFormattedCategory(from: first)
        } else {
            filters.categoriesNames = "\(AllCategories().getFormattedCategory(from: first)) and \(filters.categories.count - 1) More"
        }
    }

    private func reset() {
        onlyShowOpenNow = false
        filters.categories = ["food"]
        filters.categoriesNames = "All Food"
    }

    private func save() async {
        saveTapped = true
        dismiss()
        filters.openNow = onlyShowOpenNow
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
        Utils.writeCategoriesFilterToCache(categories: filters.categories, categoriesNames: filters.categoriesNames)
        Utils.writeIsOpenNowFilterToCache(onlyShowOpenNow: filters.openNow)
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
