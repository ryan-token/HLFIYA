//
//  FiltersState.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/29/22.
//

import SwiftUI
import MapKit

class FiltersState: ObservableObject {
    @Published var categories: Set = ["food"]
    @Published var categoriesNames = "All Food"
    @Published var prices: Set = ["All Prices"] // send to api as "1,2,3,4"
    @Published var priceName = "All Prices"
    @Published var customLatitude = CLLocationDegrees()
    @Published var customLongitude = CLLocationDegrees()
    @Published var customRadius = 5.0 // miles
}
