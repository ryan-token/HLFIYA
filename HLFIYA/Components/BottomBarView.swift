//
//  BottomBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI

struct BottomBarView: View {
    @State private var isShowingCategoriesView = false
    @State private var isShowingPriceView = false
    @State private var isShowingMapView = false
    
    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var noResultsFound: Bool
    @Binding var apiError: Bool
    
    @EnvironmentObject var locationViewModel: LocationViewModel
    @ObservedObject var filters: FiltersState
    
    var body: some View {
        HStack {
            Spacer()
            
            AsyncButton(action: {
                let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationViewModel: locationViewModel, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
                setState(fetchedBusinesses: fetchedBusinesses)
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.cyan)
                    Text("Reload")
                        .font(Font.system(.body, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("Reload Restaurants")
            
            Spacer()
            
            Button(action: {
                isShowingCategoriesView.toggle()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Categories")
                        .font(Font.system(.body, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("Select Categories")
            
            Spacer()
            
            Button(action: {
                isShowingPriceView.toggle()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.green)
                    Text("Prices")
                        .font(Font.system(.body, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("Select Prices")
            
            Spacer()
            
            Button(action: {
                isShowingMapView.toggle()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "map.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.pink)
                    Text("Location")
                        .font(Font.system(.body, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("Select Location")
            
            Spacer()
            
            .popover(isPresented: $isShowingPriceView) {
                PriceView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            }
        
            .popover(isPresented: $isShowingCategoriesView) {
                CategoriesView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            }
            
            .popover(isPresented: $isShowingMapView) {
                MapView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            }
        }
    }
    
    func setPriceFilter(prices: Set<String>, name: String) async {
        filters.prices = prices
        filters.priceName = name
        let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationViewModel: locationViewModel, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
        setState(fetchedBusinesses: fetchedBusinesses)
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

//struct BottomBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        BottomBarView()
//    }
//}
