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
    @Published var price = "1,2,3,4"
    @Published var priceName = "All Prices"
    @Published var customLatitude = CLLocationDegrees()
    @Published var customLongitude = CLLocationDegrees()
    @Published var customRadius = 10.0 // miles
}
