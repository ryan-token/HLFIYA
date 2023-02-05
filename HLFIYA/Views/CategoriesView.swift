//
//  CategoriesView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import SwiftUI

struct CategoriesView: View {
    let yelpCategories = AllCategories().getYelpCategories()
    
    @State private var onlyShowOpenNow = false
    @State private var initialOpenNowValue = false
    @State private var initialCategories = Set([""])
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
                    Section(header: Text("Hours").foregroundColor(.gray), footer: Text("Toggle on to only show places that are currently open. Toggle off to show all places.").font(Font.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)) {
                        Toggle("Currently Open", isOn: $onlyShowOpenNow)
                    }
                    
                    Section(header: Text("Types").foregroundColor(.gray)) {
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
                                    filters.categories = ["food"]
                                }
                                
                                if filters.categories.count == yelpCategories.count-1 {
                                    filters.categories = ["food"]
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
                }
                .foregroundColor(.primary)
                .navigationTitle("Choose Categories")
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            onlyShowOpenNow = false
                            filters.categories = ["food"]
                            filters.categoriesNames = "All Food"
                        }) {
                            Text("Reset")
                                .font(Font.system(.headline, design: .rounded))
                        }
                    }
                    
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        AsyncButton(action: {
                            saveTapped = true
                            dismiss()
                            filters.openNow = onlyShowOpenNow
                            let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationViewModel: locationViewModel, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices, onlyGetOpenNow: filters.openNow)
                            setState(fetchedBusinesses: fetchedBusinesses)
                            Utils.writeCategoriesFilterToCache(categories: filters.categories, categoriesNames: filters.categoriesNames)
                            Utils.writeIsOpenNowFilterToCache(onlyShowOpenNow: filters.openNow)
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
            onlyShowOpenNow = filters.openNow
            initialOpenNowValue = filters.openNow
            initialCategories = filters.categories
        }
        
        .onDisappear {
            if !saveTapped {
                onlyShowOpenNow = initialOpenNowValue
                filters.categories = initialCategories
                if filters.categories.count == 1 {
                    filters.categoriesNames = AllCategories().getFormattedCategory(from: filters.categories.first!)
                } else {
                    filters.categoriesNames = "\(AllCategories().getFormattedCategory(from: filters.categories.first!)) and \(filters.categories.count-1) More"
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

//struct CategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView()
//    }
//}
