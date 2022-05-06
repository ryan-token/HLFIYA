//
//  CategoriesPicker.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import SwiftUI

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
    let yelpCategories = Array(AllCategories().getYelpCategories())
    
    @ObservedObject var locationManager = LocationManager.shared
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(yelpCategories, id: \.self) { yelpCategory in
                        MultiPicker(title: AllCategories().getFormattedCategory(from: yelpCategory), isSelected: categoriesFilter.contains(yelpCategory)) {
                            if categoriesFilter.contains(yelpCategory) {
                                categoriesFilter.remove(yelpCategory)
                            } else {
                                categoriesFilter.insert(yelpCategory)
                            }
                            
                            if categoriesFilter.count > 0 {
                                categoriesFilter.remove("food")
                            } else {
                                categoriesFilter.insert("food")
                            }
                            
                            if yelpCategory == "food" {
                                categoriesFilter = ["food"]
                            }
                            
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
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            print("categories: \(categoriesFilter)")
            
            do {
                let fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: radiusFilter), categories: categoriesFilter, price: priceFilter)
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
