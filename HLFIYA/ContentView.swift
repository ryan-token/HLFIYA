//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI
import CoreData
import CoreLocation
import CoreLocationUI

struct ContentView: View {
    @State private var currentLocationSet = false
    @State private var nearbyBusinesses = [Business]()
    @State private var remainingBusinessesInList = Int()
    @State private var currentBusinessIndex = 0
    @State private var showRefreshButton = false
    @State private var apiError = false
    
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
                            .font(.title2)
                            .padding(5)
                            .animation(.none, value: currentBusinessIndex)
                    }
                    
                    ZStack {
                        ForEach($nearbyBusinesses.reversed()) { business in
                            CardView(business: business, remainingBusinessesInList: $remainingBusinessesInList, currentBusinessIndex: $currentBusinessIndex, totalBusinesses: nearbyBusinesses.count)
                                .padding(8)
                        }
                        
                        if remainingBusinessesInList == 0 && showRefreshButton {
                            AsyncButton(action: {
                                await refreshBusinesses(latitude: 40.678177, longitude: -73.944160, radius: 24140)
                            }, label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle")
                                    Text("Refresh Food")
                                }
                                .frame(width: 150, height: 100)
                                .font(.headline)
                                .foregroundColor(.red)
                            })
                        }
                    }
                    .zIndex(1.0)
                    
                    BottomBarView()
                }
                
                .task {
                    if !currentLocationSet {
                        print("requesting location...")
                        locationManager.requestLocation()
                    }
                    
                    if let location = locationManager.location {
                        let latitude = location.coordinate.latitude
                        let longitude = location.coordinate.longitude
                        
                        if nearbyBusinesses.isEmpty {
                            print("refreshing businesses")
                            await refreshBusinesses(latitude: latitude, longitude: longitude, radius: 24140)
                        } else {
                            print("We already have businesses, not fetching onAppear")
                        }
                    }
                }
            }
        }
    }
    
    // radius is in meters
    func refreshBusinesses(latitude: Double, longitude: Double, radius: Int) async {
        Task {
            print("fetching new business data")
            do {
                let fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: radius)
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
