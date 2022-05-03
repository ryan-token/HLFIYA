//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI

struct ContentView: View {
    @State private var currentLocationSet = false
    @State private var nearbyBusinesses = [Business]()
    @State private var remainingBusinessesInList = Int()
    @State private var currentBusinessIndex = 0
    @State private var showRefreshButton = false
    @State private var apiError = false
    
    @State private var radiusFilter = 15.0 // miles
    @State private var categoriesFilter = "food"
    @State private var categoriesName = "All Food"
    @State private var priceFilter = "1,2,3,4"
    @State private var priceName = "All Prices"
    
    @State private var businessesSwipedLeft = [Business]()
    @State private var businessesSwipedRight = [Business]()
    
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        Group {
            if locationManager.location == nil {
                LocationRequestView()
            } else {
                VStack {
                    TopBarView()
                    
                    if apiError {
                        Text("😕 Error loading businesses")
                            .foregroundColor(.gray)
                    }
                    
                    if !nearbyBusinesses.isEmpty {
                        Text(nearbyBusinesses[currentBusinessIndex].location.city)
                            .font(Font.system(.title, design: .rounded))
                            .bold()
                            .padding(5)
                            .animation(.none, value: currentBusinessIndex)
                    }
                    
                    VStack {
                        HStack {
                            Text("Category:")
                                .foregroundColor(.gray)
                            Text(categoriesName)
                                .bold()
                        }
                        .padding(.bottom, 1)
                        .animation(.interactiveSpring(), value: categoriesName)
                        
                        HStack {
                            Text("Price:")
                                .foregroundColor(.gray)
                            Text(priceName)
                                .bold()
                        }
                        .padding(.bottom, 1)
                        .animation(.interactiveSpring(), value: priceName)
                        
                        HStack {
                            Text("Radius:")
                                .foregroundColor(.gray)
                            Text("\(String(format:"%.1f", radiusFilter)) Miles")
                                .bold()
                        }
                        .animation(.interactiveSpring(), value: radiusFilter)
                    }
                    
                    ZStack {
                        if nearbyBusinesses.isEmpty {
                            ProgressView()
                                .frame(maxHeight: .infinity)
                        }
                        
                        ForEach($nearbyBusinesses.reversed()) { business in
                            CardView(business: business, nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, businessesSwipedLeft: $businessesSwipedLeft, businessesSwipedRight: $businessesSwipedRight, totalBusinesses: nearbyBusinesses.count)
                                .padding(8)
                        }
                        
                        if remainingBusinessesInList == 0 && showRefreshButton {
                            AsyncButton(action: {
                                if let location = locationManager.location {
                                    let latitude = location.coordinate.latitude
                                    let longitude = location.coordinate.longitude
                                    
                                    await refreshBusinesses(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: radiusFilter), categories: categoriesFilter, price: priceFilter)
                                }
                            }, label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle")
                                    Text("Refresh Food")
                                }
                                .frame(width: 150, height: 100)
                                .font(Font.system(.headline, design: .rounded))
                                .foregroundColor(.red)
                            })
                        }
                    }
                    .zIndex(1.0)
                    
                    BottomBarView(nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, showRefreshButton: $showRefreshButton, apiError: $apiError, radiusFilter: $radiusFilter, categoriesFilter: $categoriesFilter, categoriesName: $categoriesName, priceFilter: $priceFilter, priceName: $priceName)
                }
                
                .task {
                    if !currentLocationSet {
                        print("requesting location...")
                        LocationManager.shared.requestLocation()
                        currentLocationSet = true
                    }
                    
                    if let location = locationManager.location {
                        let latitude = location.coordinate.latitude
                        let longitude = location.coordinate.longitude
                        
                        if nearbyBusinesses.isEmpty {
                            print("refreshing businesses")
                            await refreshBusinesses(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: radiusFilter), categories: categoriesFilter, price: priceFilter)
                        } else {
                            print("We already have businesses, not fetching onAppear")
                        }
                    }
                }
            }
        }
    }
    
    // radius is in meters
    func refreshBusinesses(latitude: Double, longitude: Double, radius: Int, categories: String, price: String) async {
        Task {
            print("fetching new business data")
            do {
                let fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: radius, categories: categories, price: price)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
