//
//  BottomBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI
import MapKit

struct BottomBarView: View {
    @State private var showingCategoriesPicker = false
    @State private var showingCategoryOptions = false
    @State private var showingPriceOptions = false
    @State private var showingRadiusSlider = false
    
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var apiError: Bool

    @Binding var radiusFilter: Double
    @Binding var categoriesFilter: Set<String>
    @Binding var categoriesNames: String
    @Binding var priceFilter: String
    @Binding var priceName: String
    
    @Binding var customLatitude: CLLocationDegrees
    @Binding var customLongitude: CLLocationDegrees
    @Binding var customRadius: Double
    
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        HStack {
            Spacer()
            
            AsyncButton(action: {
                await refreshBusinesses()
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
                showingCategoriesPicker = true
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
                showingPriceOptions = true
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
                showingRadiusSlider = true
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "map.circle.fill")
                        .font(Font.system(size: 50, design: .rounded))
                        .foregroundColor(.pink)
                    Text("Radius")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            .confirmationDialog("Select a price range", isPresented: $showingPriceOptions, titleVisibility: .visible) {
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
            
            .popover(isPresented: $showingCategoriesPicker) {
                CategoriesPicker(categoriesFilter: $categoriesFilter, categoriesNames: $categoriesNames, nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, showRefreshButton: $showRefreshButton, apiError: $apiError, radiusFilter: radiusFilter, priceFilter: priceFilter, customLatitude: $customLatitude, customLongitude: $customLongitude, customRadius: $customRadius)
            }
            
            .popover(isPresented: $showingRadiusSlider) {
                RadiusSlider(radiusFilter: $radiusFilter, nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, showRefreshButton: $showRefreshButton, apiError: $apiError, categoriesFilter: categoriesFilter, priceFilter: priceFilter, customLatitude: $customLatitude, customLongitude: $customLongitude, customRadius: $customRadius)
            }
        }
    }
    
    func setPriceFilter(price: String, name: String) async {
        priceFilter = price
        priceName = name
        await refreshBusinesses()
    }
    
    func refreshBusinesses() async {
        if let location = locationManager.location {
            var latitude = location.coordinate.latitude
            var longitude = location.coordinate.longitude
            
            if customLatitude != 0.000000 && customLongitude != 0.000000 {
                latitude = customLatitude
                longitude = customLongitude
            }
            
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

//struct BottomBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        BottomBarView()
//    }
//}
