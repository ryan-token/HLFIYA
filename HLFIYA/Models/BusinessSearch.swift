//
//  BusinessSearch.swift
//  HLFIYA
//

import CoreLocation

/// The parameters for one Yelp restaurant search.
nonisolated struct BusinessSearch: Equatable {
    var latitude: Double
    var longitude: Double
    var radiusInMeters: Int
    var categories: Set<String>
    /// Comma-separated Yelp price levels, such as "1,2".
    var prices: String
    var openNow: Bool

    init(
        coordinate: CLLocationCoordinate2D,
        radiusInMeters: Int,
        categories: Set<String>,
        prices: String,
        openNow: Bool
    ) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        self.radiusInMeters = radiusInMeters
        self.categories = categories
        self.prices = prices
        self.openNow = openNow
    }
}
