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
    
    @Environment(LocationViewModel.self) private var locationViewModel
    var filters: FiltersState
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                isShowingCategoriesView.toggle()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.pink)
                    Text("Categories")
                        .font(Font.system(.body, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("Select Categories")
            .popover(isPresented: $isShowingCategoriesView) {
                CategoriesView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            }
            
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
            .popover(isPresented: $isShowingPriceView) {
                PriceView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            }
            
            Spacer()
            
            Button(action: {
                isShowingMapView.toggle()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "map.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.blue)
                    Text("Location")
                        .font(Font.system(.body, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("Select Location")
            .popover(isPresented: $isShowingMapView) {
                MapView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            }
            
            Spacer()
        }
    }
}

//struct BottomBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        BottomBarView()
//    }
//}
