//
//  FiltersState.swift
//  HLFIYA
//

import CoreLocation
import Observation

/// The search filters shared by the main screen and the filter sheets.
///
/// Sheets edit a draft copy and call one of the `apply` methods on save, which also
/// persists the new values so they survive relaunches, unless the filters are
/// in memory only, as in tests.
@Observable
final class FiltersState {
    private(set) var openNow = false
    private(set) var categories = CategorySelection()
    private(set) var prices = PriceSelection()
    /// A custom search center, or `nil` to search around the person's location.
    private(set) var customCoordinate: CLLocationCoordinate2D?
    /// The search radius in miles.
    private(set) var radius = FiltersState.defaultRadius

    /// The radius used when no custom location has been saved.
    static let defaultRadius = 5.0

    /// Yelp's API caps the search radius at 40,000 m (about 24.85 miles).
    static let maximumRadius = 24.854847

    private let isInMemory: Bool

    init(inMemory: Bool = false) {
        isInMemory = inMemory
    }

    /// Restores the filters saved by the previous session.
    func restoreFromCache() {
        openNow = Utils.getIsOpenNowFilterCache()
        categories = CategorySelection(categories: Utils.getCategoriesFilterCache().categories)
        prices = PriceSelection(prices: Utils.getPricesFilterCache().prices)

        let location = Utils.getLocationFilterCache()
        customCoordinate = Self.coordinate(latitude: location.customLatitude, longitude: location.customLongitude)
        radius = location.customRadius > 0 ? location.customRadius : Self.defaultRadius
    }

    func applyCategories(_ selection: CategorySelection, openNow: Bool) {
        categories = selection
        self.openNow = openNow
        guard !isInMemory else { return }
        Utils.writeCategoriesFilterToCache(categories: selection.categories, categoriesNames: selection.summary)
        Utils.writeIsOpenNowFilterToCache(onlyShowOpenNow: openNow)
    }

    func applyPrices(_ selection: PriceSelection) {
        prices = selection
        guard !isInMemory else { return }
        Utils.writePricesFilterToCache(prices: selection.prices, priceName: selection.summary)
    }

    func applyLocation(center: CLLocationCoordinate2D, radius: Double) {
        customCoordinate = center
        self.radius = min(radius, Self.maximumRadius)
        guard !isInMemory else { return }
        Utils.writeLocationFilterToCache(
            customLatitude: center.latitude,
            customLongitude: center.longitude,
            customRadius: self.radius
        )
    }

    /// Converts the cache's "0, 0 means unset" convention into an optional coordinate.
    private static func coordinate(
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees
    ) -> CLLocationCoordinate2D? {
        latitude == 0 && longitude == 0 ? nil : CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
