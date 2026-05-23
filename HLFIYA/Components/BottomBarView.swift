//
//  BottomBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI

struct BottomBarView: View {
    @State private var isShowingCategoriesView = false
    @State private var isShowingPriceView = false
    @State private var isShowingMapView = false

    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var noResultsFound: Bool
    @Binding var apiError: Bool

    @Environment(LocationViewModel.self) private var locationViewModel
    var filters: FiltersState

    private let buttonSize: CGFloat = 30

    var body: some View {
        HStack {
            Spacer()

            BottomBarItem(
                title: "Categories",
                systemImage: "line.3.horizontal.decrease.circle",
                tintColor: .pink,
                buttonSize: buttonSize,
                accessibilityLabel: "Select Categories",
                action: { isShowingCategoriesView.toggle() }
            )
            .popover(isPresented: $isShowingCategoriesView) {
                CategoriesView(
                    nearbyRestaurants: $nearbyRestaurants,
                    remainingRestaurantsInList: $remainingRestaurantsInList,
                    currentRestaurantIndex: $currentRestaurantIndex,
                    showRefreshButton: $showRefreshButton,
                    noResultsFound: $noResultsFound,
                    apiError: $apiError,
                    filters: filters
                )
            }

            Spacer()

            BottomBarItem(
                title: "Price",
                systemImage: "dollarsign.circle",
                tintColor: .green,
                buttonSize: buttonSize,
                accessibilityLabel: "Select Prices",
                action: { isShowingPriceView.toggle() }
            )
            .popover(isPresented: $isShowingPriceView) {
                PriceView(
                    nearbyRestaurants: $nearbyRestaurants,
                    remainingRestaurantsInList: $remainingRestaurantsInList,
                    currentRestaurantIndex: $currentRestaurantIndex,
                    showRefreshButton: $showRefreshButton,
                    noResultsFound: $noResultsFound,
                    apiError: $apiError,
                    filters: filters
                )
            }

            Spacer()

            BottomBarItem(
                title: "Location",
                systemImage: "map.circle",
                tintColor: .blue,
                buttonSize: buttonSize,
                accessibilityLabel: "Select Location",
                action: { isShowingMapView.toggle() }
            )
            .popover(isPresented: $isShowingMapView) {
                MapView(
                    nearbyRestaurants: $nearbyRestaurants,
                    remainingRestaurantsInList: $remainingRestaurantsInList,
                    currentRestaurantIndex: $currentRestaurantIndex,
                    showRefreshButton: $showRefreshButton,
                    noResultsFound: $noResultsFound,
                    apiError: $apiError,
                    filters: filters
                )
            }

            Spacer()
        }
    }
}

private struct BottomBarItem: View {
    let title: String
    let systemImage: String
    let tintColor: Color
    let buttonSize: CGFloat
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 5) {
            TintedGlassButton(
                action: action,
                label: {
                    Image(systemName: systemImage)
                        .font(.system(size: buttonSize))
                },
                tintColor: tintColor,
                style: .prominent
            )

            Text(title)
                .foregroundStyle(.gray)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}
