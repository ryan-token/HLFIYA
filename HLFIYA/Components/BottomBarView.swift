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

    let buttonSize: CGFloat = 30

    var body: some View {
        HStack {
            Spacer()

            VStack(spacing: 5) {
                TintedGlassButton(
                    action: {
                        isShowingCategoriesView.toggle()
                    },
                    label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(Font.system(size: buttonSize, design: .rounded))
                    },
                    tintColor: .pink,
                    style: .prominent
                )

                Text("Categories")
                    .font(Font.system(.body, design: .rounded))
                    .foregroundColor(.gray)
            }
            .accessibilityLabel("Select Categories")
            .popover(isPresented: $isShowingCategoriesView) {
                CategoriesView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            }
            
            Spacer()

            VStack(spacing: 5) {
                TintedGlassButton(
                    action: {
                        isShowingPriceView.toggle()
                    },
                    label: {
                        Image(systemName: "dollarsign.circle")
                            .font(Font.system(size: buttonSize, design: .rounded))
                    },
                    tintColor: .green,
                    style: .prominent
                )

                Text("Price")
                    .font(Font.system(.body, design: .rounded))
                    .foregroundColor(.gray)
            }
            .accessibilityLabel("Select Prices")
            .popover(isPresented: $isShowingPriceView) {
                PriceView(nearbyRestaurants: $nearbyRestaurants, remainingRestaurantsInList: $remainingRestaurantsInList, currentRestaurantIndex: $currentRestaurantIndex, showRefreshButton: $showRefreshButton, noResultsFound: $noResultsFound, apiError: $apiError, filters: filters)
            }
            
            Spacer()

            VStack(spacing: 5) {
                TintedGlassButton(
                    action: {
                        isShowingMapView.toggle()
                    },
                    label: {
                        Image(systemName: "map.circle")
                            .font(Font.system(size: buttonSize, design: .rounded))
                    },
                    tintColor: .blue,
                    style: .prominent
                )

                Text("Location")
                    .font(Font.system(.body, design: .rounded))
                    .foregroundColor(.gray)
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
