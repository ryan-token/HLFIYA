//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var currentLocationSet = false
    @State private var nearbyBusinesses = [Business]()
    @State private var remainingBusinessesInList = Int()
    @State private var currentBusinessIndex = 0
    @State private var showRefreshButton = false
    @State private var apiError = false
    
    @State private var radiusFilter = 10.0 // miles
    @State private var categoriesFilter: Set = ["food"]
    @State private var categoriesNames = "All Food"
    @State private var priceFilter = "1,2,3,4"
    @State private var priceName = "All Prices"
    
    @State private var businessesSwipedLeft = [Business]()
    @State private var businessesSwipedRight = [Business]()
    
    @State private var customLatitude = CLLocationDegrees()
    @State private var customLongitude = CLLocationDegrees()
    @State private var customRadius = 10.0
    
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        Group {
            if locationManager.location == nil {
                LocationRequestView()
            } else {
                VStack {
                    Text("customLatitude: \(customLatitude)")
                    Text("customLongitude: \(customLongitude)")
                    Text("customRadius: \(customRadius)")
                    TopBarView(customLatitude: $customLatitude, customLongitude: $customLongitude, customRadius: $customRadius)
                    
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
                            Text("Categories:")
                                .foregroundColor(.gray)
                            Text(categoriesNames)
                                .bold()
                        }
                        .padding(.bottom, 1)
                        .animation(.interactiveSpring(), value: categoriesFilter)
                        
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
                            Text("\(String(format:"%.1f", customRadius)) Miles")
                                .bold()
                        }
                        .animation(.interactiveSpring(), value: customRadius)
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
                                    var latitude = location.coordinate.latitude
                                    var longitude = location.coordinate.longitude
                                    
                                    if customLatitude != 0.000000 && customLongitude != 0.000000 {
                                        latitude = customLatitude
                                        longitude = customLongitude
                                    }
                                    
                                    await refreshBusinesses(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: customRadius), categories: categoriesFilter, price: priceFilter)
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
                    
                    BottomBarView(nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, showRefreshButton: $showRefreshButton, apiError: $apiError, radiusFilter: $radiusFilter, categoriesFilter: $categoriesFilter, categoriesNames: $categoriesNames, priceFilter: $priceFilter, priceName: $priceName, customLatitude: $customLatitude, customLongitude: $customLongitude, customRadius: $customRadius)
                }
                
                .task {
                    if !currentLocationSet {
                        print("requesting location...")
                        LocationManager.shared.requestLocation()
                        currentLocationSet = true
                    }
                    
                    if let location = locationManager.location {
                        var latitude = location.coordinate.latitude
                        var longitude = location.coordinate.longitude
                        
                        if customLatitude != 0.000000 && customLongitude != 0.000000 {
                            latitude = customLatitude
                            longitude = customLongitude
                        }
                        
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
    func refreshBusinesses(latitude: Double, longitude: Double, radius: Int, categories: Set<String>, price: String) async {
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
