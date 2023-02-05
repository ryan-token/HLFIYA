//
//  PriceView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/29/22.
//

import SwiftUI

struct PriceView: View {
    let priceOptions = AllPrices().getPriceOptions()
    
    @State private var initialPrices = Set([""])
    @State private var saveTapped = false
    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var noResultsFound: Bool
    @Binding var apiError: Bool
    
    @EnvironmentObject var locationViewModel: LocationViewModel
    @ObservedObject var filters: FiltersState
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(priceOptions, id: \.self) { priceOption in
                        MultiPicker(title: AllPrices().getFormattedPrice(from: priceOption), isSelected: filters.prices.contains(priceOption)) {
                            // add or remove the selected category
                            if filters.prices.contains(priceOption) {
                                filters.prices.remove(priceOption)
                            } else {
                                filters.prices.insert(priceOption)
                            }
                            
                            // Only allow 'All Food' to be selected if nothing else is selected
                            if filters.prices.count > 0 {
                                filters.prices.remove("All Prices")
                            } else {
                                filters.prices = ["All Prices"]
                            }
                            
                            // select 'All Prices' if user manually selects all of them
                            if filters.prices.count == priceOptions.count-1 {
                                filters.prices = ["All Prices"]
                            }
                            
                            // If user specifically selects 'All Prices', deselect everything else
                            if priceOption == "All Prices" {
                                filters.prices = ["All Prices"]
                            }
                            
                            // Set the priceNames option
                            if filters.prices.count == 1 {
                                filters.priceName = AllPrices().getFormattedPrice(from: filters.prices.first!)
                            } else {
                                filters.priceName = AllPrices().getPriceNames(from: filters.prices)
                            }
                        }
                    }
                }
                .foregroundColor(.primary)
                .navigationTitle("Choose Prices")
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            filters.prices = ["All Prices"]
                            filters.priceName = "All Prices"
                        }) {
                            Text("Reset")
                                .font(Font.system(.headline, design: .rounded))
                        }
                    }
                    
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        AsyncButton(action: {
                            saveTapped = true
                            dismiss()
                            let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationViewModel: locationViewModel, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices, onlyGetOpenNow: filters.openNow)
                            setState(fetchedBusinesses: fetchedBusinesses)
                            Utils.writePricesFilterToCache(prices: filters.prices, priceName: filters.priceName)
                        }) {
                            Text("Save")
                                .font(Font.system(.headline, design: .rounded))
                        }
                    }
                 }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(Color(UIColor(named: "fuchsia")!))
        
        .onAppear {
            initialPrices = filters.prices
        }
        
        .onDisappear {
            if !saveTapped {
                filters.prices = initialPrices
                if filters.prices.count == 1 {
                    filters.priceName = AllPrices().getFormattedPrice(from: filters.prices.first!)
                } else {
                    filters.priceName = AllPrices().getPriceNames(from: filters.prices)
                }
            }
        }
    }
    
    func setState(fetchedBusinesses: [Business]) {
        nearbyRestaurants = fetchedBusinesses
        remainingRestaurantsInList = fetchedBusinesses.count
        currentRestaurantIndex = 0
        showRefreshButton = true
        apiError = false
        if fetchedBusinesses.isEmpty {
            noResultsFound = true
        } else {
            noResultsFound = false
        }
    }
}

//struct PriceView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView()
//    }
//}
