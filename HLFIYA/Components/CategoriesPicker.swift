//
//  CategoriesPicker.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import SwiftUI
import MapKit

struct CategoriesPicker: View {
    @Binding var categoriesFilter: Set<String>
    @Binding var categoriesNames: String
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var apiError: Bool
    
    var radiusFilter: Double
    var priceFilter: String
    
    @Binding var customLatitude: CLLocationDegrees
    @Binding var customLongitude: CLLocationDegrees
    @Binding var customRadius: Double
    
    let yelpCategories = Array(AllCategories().getYelpCategories())
    
    @ObservedObject var locationManager = LocationManager.shared
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(yelpCategories, id: \.self) { yelpCategory in
                        MultiPicker(title: AllCategories().getFormattedCategory(from: yelpCategory), isSelected: categoriesFilter.contains(yelpCategory)) {
                            // add or remove the selected category
                            if categoriesFilter.contains(yelpCategory) {
                                categoriesFilter.remove(yelpCategory)
                            } else {
                                categoriesFilter.insert(yelpCategory)
                            }
                            
                            // Only allow 'All Food' to be selected if nothing else is selected
                            if categoriesFilter.count > 0 {
                                categoriesFilter.remove("food")
                            } else {
                                categoriesFilter.insert("food")
                            }
                            
                            // If user specifically selects 'All Food', deselect everything else
                            if yelpCategory == "food" {
                                categoriesFilter = ["food"]
                            }
                            
                            // Set the categoriesNames option
                            if categoriesFilter.count == 1 {
                                categoriesNames = AllCategories().getFormattedCategory(from: categoriesFilter.first!)
                            } else {
                                categoriesNames = "\(AllCategories().getFormattedCategory(from: categoriesFilter.first!)) and \(categoriesFilter.count-1) More"
                            }
                        }
                    }
                }
                .navigationTitle("Choose Categories")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Reset") {
                            categoriesFilter = ["food"]
                            categoriesNames = "All Food"
                        }
                    }
                    
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        AsyncButton(action: {
                            dismiss()
                            await refreshBusinesses()
                        }) {
                            Text("Close")
                        }
                    }
                 }
            }
        }
    }
    
    func refreshBusinesses() async {
        if let location = locationManager.location {
            var latitude = location.coordinate.latitude
            var longitude = location.coordinate.longitude
            
            if customLatitude != 0.000000 && customLongitude != 0.000000 {
                latitude = customLatitude
                longitude = customLongitude
            }
            
            print("categories: \(categoriesFilter)")
            
            do {
                let fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: customRadius), categories: categoriesFilter, price: priceFilter)
                nearbyBusinesses = fetchedBusinesses
                print(nearbyBusinesses)
                remainingBusinessesInList = fetchedBusinesses.count
                currentBusinessIndex = 0
                showRefreshButton = true
                apiError = false
            } catch {
                print("Request failed with error: \(error)")
                apiError = true
            }
        }
    }
}

//struct CategoriesPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesPicker()
//    }
//}
