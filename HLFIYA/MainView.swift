//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI
import MapKit

struct MainView: View {
    @State private var currentLocationSet = false
    @State private var nearbyBusinesses = [Business]()
    @State private var remainingBusinessesInList = Int()
    @State private var currentBusinessIndex = 0
    @State private var showRefreshButton = false
    @State private var apiError = false
    
    @State private var businessesSwipedLeft = [Business]()
    @State private var businessesSwipedRight = [Business]()
    
    @StateObject var filters = FiltersState()
    @ObservedObject var locationManager = LocationManager.shared
    
    init() {
        let design = UIFontDescriptor.SystemDesign.rounded
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            .withDesign(design)!
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits.traitBold)!
        let font = UIFont.init(descriptor: descriptor, size: 30)
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : font]
    }
    
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
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Categories:")
                                .foregroundColor(.gray)
                            Text(filters.categoriesNames)
                                .bold()
                        }
                        .animation(.interactiveSpring(), value: filters.categories)
                        
                        HStack {
                            Text("Prices:")
                                .foregroundColor(.gray)
                            Text(filters.priceName)
                                .bold()
                        }
                        .animation(.interactiveSpring(), value: filters.priceName)
                        
                        HStack {
                            Text("Radius:")
                                .foregroundColor(.gray)
                            Text("\(String(format:"%.1f", filters.customRadius)) Miles")
                                .bold()
                        }
                        .animation(.interactiveSpring(), value: filters.customRadius)
                    }
                    .font(Font.system(.body, design: .rounded))
                    
                    ZStack {
                        if nearbyBusinesses.isEmpty {
                            ProgressView()
                                .frame(maxHeight: .infinity)
                        }
                        
                        ForEach($nearbyBusinesses.reversed()) { business in
                            CardView(totalBusinesses: nearbyBusinesses.count, business: business, nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, businessesSwipedLeft: $businessesSwipedLeft, businessesSwipedRight: $businessesSwipedRight)
                                .padding(8)
                        }
                        
                        if remainingBusinessesInList == 0 && showRefreshButton {
                            AsyncButton(action: {
                                let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationManager: locationManager, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
                                setState(fetchedBusinesses: fetchedBusinesses)
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
                    
                    BottomBarView(nearbyBusinesses: $nearbyBusinesses, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, showRefreshButton: $showRefreshButton, apiError: $apiError, filters: filters)
                }
                
                .task {
                    if !currentLocationSet {
                        print("requesting location...")
                        LocationManager.shared.requestLocation()
                        currentLocationSet = true
                    }
                    
                    if nearbyBusinesses.isEmpty {
                        print("refreshing businesses")
                        let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationManager: locationManager, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
                        setState(fetchedBusinesses: fetchedBusinesses)
                    } else {
                        print("We already have businesses, not fetching onAppear")
                    }
                }
            }
        }
    }
    
    // radius is in meters
    static func refreshBusinesses(customLatitude: CLLocationDegrees, customLongitude: CLLocationDegrees, locationManager: LocationManager, customRadius: Double, categories: Set<String>, prices: Set<String>) async -> [Business] {
        var latitude: CLLocationDegrees
        var longitude: CLLocationDegrees
        var fetchedBusinesses: [Business]
        
        if customLatitude != 0.000000 && customLongitude != 0.000000 {
            latitude = customLatitude
            longitude = customLongitude
        } else {
            if let currentLocation = locationManager.location {
                latitude = currentLocation.coordinate.latitude
                longitude = currentLocation.coordinate.longitude
            } else {
                latitude = 0.000000
                longitude = 0.000000
            }
        }
        
        var stringPrices: String
        if prices == ["All Prices"] {
            stringPrices = "1,2,3,4"
        } else {
            stringPrices = prices.joined(separator: ",")
        }
        
        do {
            fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: customRadius), categories: categories, prices: stringPrices)
        } catch {
            print("Request failed with error: \(error)")
            fetchedBusinesses = []
        }
        
        return fetchedBusinesses
    }
    
    func setState(fetchedBusinesses: [Business]) {
        nearbyBusinesses = fetchedBusinesses
        remainingBusinessesInList = fetchedBusinesses.count
        currentBusinessIndex = 0
        showRefreshButton = true
        apiError = false
    }
    
    func checkForApiError(fetchedBusinesses: [Business]) {
        if (fetchedBusinesses.count == 0) {
            apiError = true
        } else {
            apiError = false
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
