//
//  BottomBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI
import MapKit

struct BottomBarView: View {
    @State private var isShowingCategoriesPicker = false
    @State private var isShowingCategoryOptions = false
    @State private var isShowingPriceOptions = false
    @State private var isShowingMapView = false
    
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var apiError: Bool
    
    @ObservedObject var filters: FiltersState
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        HStack {
            Spacer()
            
            AsyncButton(action: {
                let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationManager: locationManager, customRadius: filters.customRadius, categories: filters.categories, price: filters.price)
                setState(fetchedBusinesses: fetchedBusinesses)
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.cyan)
                    Text("Reload")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                isShowingCategoriesPicker.toggle()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Categories")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                isShowingPriceOptions.toggle()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.green)
                    Text("Price")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                isShowingMapView.toggle()
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "map.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.pink)
                    Text("Location")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            .confirmationDialog("Select a price range", isPresented: $isShowingPriceOptions, titleVisibility: .visible) {
                AsyncButton(action: {
                    await setPriceFilter(price: "1", name: "$")
                }) {
                    Text("$")
                }
                
                AsyncButton(action: {
                    await setPriceFilter(price: "2", name: "$$")
                }) {
                    Text("$$")
                }
                
                AsyncButton(action: {
                    await setPriceFilter(price: "3", name: "$$$")
                }) {
                    Text("$$$")
                }
                
                AsyncButton(action: {
                    await setPriceFilter(price: "4", name: "$$$$")
                }) {
                    Text("$$$$")
                }
                
                AsyncButton(action: {
                    await setPriceFilter(price: "1,2,3,4", name: "All Prices")
                }) {
                    Text("All Prices")
                }
            }
            
            .popover(isPresented: $isShowingCategoriesPicker) {
                CategoriesPicker(nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, showRefreshButton: $showRefreshButton, apiError: $apiError, filters: filters)
            }
            
            .popover(isPresented: $isShowingMapView) {
                MapView(filters: filters)
            }
        }
    }
    
    func setPriceFilter(price: String, name: String) async {
        filters.price = price
        filters.priceName = name
        let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationManager: locationManager, customRadius: filters.customRadius, categories: filters.categories, price: filters.price)
        setState(fetchedBusinesses: fetchedBusinesses)
    }
    
    func setState(fetchedBusinesses: [Business]) {
        nearbyBusinesses = fetchedBusinesses
        remainingBusinessesInList = fetchedBusinesses.count
        currentBusinessIndex = 0
        showRefreshButton = true
        apiError = false
    }
}

//struct BottomBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        BottomBarView()
//    }
//}
