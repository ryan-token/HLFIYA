//
//  FiltersState.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/29/22.
//

import SwiftUI
import MapKit

@MainActor
@Observable
final class FiltersState {
    var openNow = false
    var categories: Set = ["food"]
    var categoriesNames = "All Food"
    var prices: Set = ["All Prices"] // send to api as "1,2,3,4"
    var priceName = "All Prices"
    var customLatitude = CLLocationDegrees()
    var customLongitude = CLLocationDegrees()
    var customRadius = 5.0 // miles
}
