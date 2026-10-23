//
//  RestaurantInfoSection.swift
//  HLFIYA
//

import SwiftUI

/// The restaurant's phone number, address, and opening hours.
struct RestaurantInfoSection: View {
    let details: RestaurantInfo

    var body: some View {
        Section("Information") {
            if let phone = details.phone, !phone.isEmpty {
                PhoneRow(phone: phone, displayPhone: details.displayPhone ?? phone)
            }

            if !details.addressLines.isEmpty {
                AddressRow(addressLines: details.addressLines, latitude: details.latitude, longitude: details.longitude)
            }

            if !details.openHours.isEmpty {
                HoursRow(openHours: details.openHours)
            }
        }
    }
}
