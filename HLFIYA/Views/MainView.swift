//
//  MainView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI
import CoreData
import MapKit
import GoogleMobileAds
import StoreKit

struct MainView: View {
    @State private var nearbyRestaurants = [Business]()
    @State private var remainingRestaurantsInList = 0
    @State private var currentRestaurantIndex = 0
    @State private var showRefreshButton = false
    @State private var noResultsFound = false
    @State private var apiError = false
    @State private var isShowingError = false
    @State private var errorTitle = ""

    @State private var restaurantsSwipedLeft = [Business]()
    @State private var restaurantsSwipedRight = [Business]()

    @State private var filters = FiltersState()
    @State private var storeManager = StoreManager()
    @Environment(LocationViewModel.self) private var locationViewModel

    @Environment(\.managedObjectContext) private var moc
    @AppStorage("userHasOpenedAppBefore") private var userHasOpenedAppBefore = false

    var body: some View {
        VStack {
            TopBarView()

            if apiError {
                Text("😕 Error loading restaurants")
                    .foregroundStyle(.gray)
            }

            CityHeaderView(city: nearbyRestaurants[safe: currentRestaurantIndex]?.location?.city)

            FilterSummaryView(filters: filters)

            ZStack {
                if noResultsFound {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try changing the filters at the bottom.")
                    )
                } else if nearbyRestaurants.isEmpty && !apiError {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if !nearbyRestaurants.isEmpty {
                    CardStack(
                        nearbyRestaurants: $nearbyRestaurants,
                        remainingRestaurantsInList: $remainingRestaurantsInList,
                        currentRestaurantIndex: $currentRestaurantIndex,
                        restaurantsSwipedLeft: $restaurantsSwipedLeft,
                        restaurantsSwipedRight: $restaurantsSwipedRight
                    )
                }

                if remainingRestaurantsInList <= 0 && showRefreshButton && !noResultsFound {
                    AsyncButton(action: refresh) {
                        Label("Refresh Food", systemImage: "arrow.clockwise.circle")
                            .frame(width: 150, height: 100)
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .zIndex(1)

            BottomBarView(
                nearbyRestaurants: $nearbyRestaurants,
                remainingRestaurantsInList: $remainingRestaurantsInList,
                currentRestaurantIndex: $currentRestaurantIndex,
                showRefreshButton: $showRefreshButton,
                noResultsFound: $noResultsFound,
                apiError: $apiError,
                filters: filters
            )

            if storeManager.purchasedIds.isEmpty {
                RemoveAdsBannerView(
                    onPurchase: purchaseRemoveAds(product:)
                )
            }
        }
        .task { await loadInitialRestaurants() }
        .onAppear { ensureLocationAndFavoritesList() }
        .environment(storeManager)
        .alert(errorTitle, isPresented: $isShowingError) {}
    }

    private func loadInitialRestaurants() async {
        Utils.clearAnyCacheFilesOverAMonthOld()

        let localYelpCache = Utils.getLocalYelpCache()

        if !localYelpCache.isEmpty {
            setState(fetchedBusinesses: localYelpCache)
            useCachedFilters()
            return
        }

        guard nearbyRestaurants.isEmpty else { return }
        await refresh()
    }

    private func refresh() async {
        let fetched = await MainView.refreshBusinesses(
            customLatitude: filters.customLatitude,
            customLongitude: filters.customLongitude,
            locationViewModel: locationViewModel,
            customRadius: filters.customRadius,
            categories: filters.categories,
            prices: filters.prices,
            onlyGetOpenNow: filters.openNow
        )
        setState(fetchedBusinesses: fetched)
    }

    private func ensureLocationAndFavoritesList() {
        if locationViewModel.location == nil {
            locationViewModel.location = CLLocation(latitude: 37.334633, longitude: -122.012682)
        }

        if !userHasOpenedAppBefore && !itemExists("Favorites") {
            let favoritesList = SavedList(context: moc)
            favoritesList.name = "Favorites"
            try? moc.save()
        }

        if !userHasOpenedAppBefore {
            userHasOpenedAppBefore = true
        }
    }

    // radius is in meters
    static func refreshBusinesses(
        customLatitude: CLLocationDegrees,
        customLongitude: CLLocationDegrees,
        locationViewModel: LocationViewModel,
        customRadius: Double,
        categories: Set<String>,
        prices: Set<String>,
        onlyGetOpenNow: Bool
    ) async -> [Business] {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees

        if customLatitude != 0.0 && customLongitude != 0.0 {
            latitude = customLatitude
            longitude = customLongitude
        } else if let currentLocation = locationViewModel.location {
            latitude = currentLocation.coordinate.latitude
            longitude = currentLocation.coordinate.longitude
        } else {
            latitude = 37.334633
            longitude = -122.012682
        }

        let stringPrices = prices == ["All Prices"] ? "1,2,3,4" : prices.joined(separator: ",")

        do {
            return try await BusinessFetcher.getBusinessesNear(
                latitude: latitude,
                longitude: longitude,
                radius: Utils.convertMilesToMeters(miles: customRadius),
                categories: categories,
                prices: stringPrices,
                onlyGetOpenNow: onlyGetOpenNow
            )
        } catch {
            print("Request failed with error: \(error)")
            return []
        }
    }

    private func setState(fetchedBusinesses: [Business]) {
        nearbyRestaurants = fetchedBusinesses
        remainingRestaurantsInList = fetchedBusinesses.count
        currentRestaurantIndex = 0
        showRefreshButton = true
        apiError = false
        noResultsFound = fetchedBusinesses.isEmpty
    }

    private func purchaseRemoveAds(product: Product) async {
        do {
            _ = try await storeManager.purchase(product)
        } catch StoreError.failedVerification {
            HapticGenerator.playErrorHaptic()
            errorTitle = "Your purchase could not be verified by the App Store"
            isShowingError.toggle()
        } catch {
            HapticGenerator.playErrorHaptic()
            print("Failed purchase for \(product.id): \(error)")
        }
    }

    private func useCachedFilters() {
        filters.openNow = Utils.getIsOpenNowFilterCache()

        let categoriesCache = Utils.getCategoriesFilterCache()
        filters.categories = categoriesCache.categories
        filters.categoriesNames = categoriesCache.categoriesNames

        let pricesCache = Utils.getPricesFilterCache()
        filters.prices = pricesCache.prices
        filters.priceName = pricesCache.priceName

        let locationCache = Utils.getLocationFilterCache()
        filters.customLatitude = locationCache.customLatitude
        filters.customLongitude = locationCache.customLongitude
        filters.customRadius = locationCache.customRadius
    }

    private func itemExists(_ item: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedList")
        fetchRequest.predicate = NSPredicate(format: "name == %@", item)
        return ((try? moc.count(for: fetchRequest)) ?? 0) > 0
    }
}

private struct CityHeaderView: View {
    let city: String?

    var body: some View {
        if let city {
            Text(city)
                .font(.title)
                .bold()
                .padding(5)
        } else {
            ProgressView()
                .font(.largeTitle)
                .padding(5)
        }
    }
}

private struct FilterSummaryView: View {
    let filters: FiltersState

    var body: some View {
        VStack(spacing: 10) {
            LabeledRow(label: "Categories:") {
                Text(filters.categoriesNames)
                    .bold()
                    .lineLimit(1)
            }

            LabeledRow(label: "Prices:") {
                Text(filters.priceName).bold()
            }

            LabeledRow(label: "Location:") {
                Text("Within \(filters.customRadius, format: .number.precision(.fractionLength(1))) Miles")
                    .bold()
            }
        }
    }
}

private struct LabeledRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.gray)
            content
        }
    }
}

private struct CardStack: View {
    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var restaurantsSwipedLeft: [Business]
    @Binding var restaurantsSwipedRight: [Business]

    var body: some View {
        ForEach($nearbyRestaurants.reversed()) { restaurant in
            CardView(
                totalRestaurants: nearbyRestaurants.count,
                restaurant: restaurant,
                nearbyRestaurants: $nearbyRestaurants,
                remainingRestaurantsInList: $remainingRestaurantsInList,
                currentRestaurantIndex: $currentRestaurantIndex,
                restaurantsSwipedLeft: $restaurantsSwipedLeft,
                restaurantsSwipedRight: $restaurantsSwipedRight
            )
            .padding(8)
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        guard let current = nearbyRestaurants[safe: currentRestaurantIndex] else { return "" }
        let rating = (current.rating ?? 0.0).formatted(.number.precision(.fractionLength(1)))
        return "\(current.name ?? ""), \(rating) stars, \(current.price?.count ?? 0) dollar signs, \(current.categories?.first?.title ?? ""). Swipe left to skip, swipe right for details."
    }
}

private struct RemoveAdsBannerView: View {
    @Environment(StoreManager.self) private var storeManager
    let onPurchase: (Product) async -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if let removeAdsProduct = storeManager.products.first {
                AsyncButton {
                    await onPurchase(removeAdsProduct)
                } label: {
                    Text("Remove Ads")
                        .font(.callout)
                        .foregroundStyle(.fuchsia)
                }
            }
            GADBannerViewController()
                .frame(width: AdSizeBanner.size.width, height: AdSizeBanner.size.height)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    MainView()
        .environment(LocationViewModel())
}
