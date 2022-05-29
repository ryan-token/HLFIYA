//
//  CategoriesPicker.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import SwiftUI
import MapKit

struct CategoriesPicker: View {
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var apiError: Bool
    
    let yelpCategories = Array(AllCategories().getYelpCategories())
    
    @ObservedObject var filters: FiltersState
    @ObservedObject var locationManager = LocationManager.shared
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(yelpCategories, id: \.self) { yelpCategory in
                        MultiPicker(title: AllCategories().getFormattedCategory(from: yelpCategory), isSelected: filters.categories.contains(yelpCategory)) {
                            // add or remove the selected category
                            if filters.categories.contains(yelpCategory) {
                                filters.categories.remove(yelpCategory)
                            } else {
                                filters.categories.insert(yelpCategory)
                            }
                            
                            // Only allow 'All Food' to be selected if nothing else is selected
                            if filters.categories.count > 0 {
                                filters.categories.remove("food")
                            } else {
                                filters.categories.insert("food")
                            }
                            
                            // If user specifically selects 'All Food', deselect everything else
                            if yelpCategory == "food" {
                                filters.categories = ["food"]
                            }
                            
                            // Set the categoriesNames option
                            if filters.categories.count == 1 {
                                filters.categoriesNames = AllCategories().getFormattedCategory(from: filters.categories.first!)
                            } else {
                                filters.categoriesNames = "\(AllCategories().getFormattedCategory(from: filters.categories.first!)) and \(filters.categories.count-1) More"
                            }
                        }
                    }
                }
                .navigationTitle("Choose Categories")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Reset") {
                            filters.categories = ["food"]
                            filters.categoriesNames = "All Food"
                        }
                    }
                    
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        AsyncButton(action: {
                            dismiss()
                            let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationManager: locationManager, customRadius: filters.customRadius, categories: filters.categories, price: filters.price)
                            setState(fetchedBusinesses: fetchedBusinesses)
                        }) {
                            Text("Close")
                        }
                    }
                 }
            }
        }
    }
    
    func setState(fetchedBusinesses: [Business]) {
        nearbyBusinesses = fetchedBusinesses
        remainingBusinessesInList = fetchedBusinesses.count
        currentBusinessIndex = 0
        showRefreshButton = true
        apiError = false
    }
}

//struct CategoriesPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesPicker()
//    }
//}
