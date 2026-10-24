//
//  RestaurantInfo.swift
//  HLFIYA
//

import Foundation

/// The contact, address, and hours details shown in a restaurant's information section.
nonisolated struct RestaurantInfo: Equatable {
    var phone: String?
    var displayPhone: String?
    var latitude: Double?
    var longitude: Double?
    var addressLines: [String]
    var openHours: [BusinessDetails.Hour]

    init(_ details: BusinessDetails) {
        phone = details.phone
        displayPhone = details.displayPhone
        latitude = details.coordinates?.latitude
        longitude = details.coordinates?.longitude
        addressLines = (details.location?.displayAddress ?? []).filter { !$0.isEmpty }
        openHours = details.hours?.first?.open ?? []
    }
}
