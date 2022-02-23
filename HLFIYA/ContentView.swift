//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var nearbyBusinesses = [Business]()
    @State private var apiError = false
    
    var body: some View {
        VStack {
            TopBarView()
            
            if apiError {
                Text("😕 Error loading businesses")
                    .foregroundColor(.gray)
            }
            
            ZStack {
                ForEach($nearbyBusinesses) { business in
                    CardView(business: business)
                        .padding(8)
                }
            }
            .zIndex(1.0)
            
            BottomBarView()
        }
        
        .task {
            if nearbyBusinesses.isEmpty {
                print("refreshing businesses")
                await refreshBusinesses(latitude: 37.786882, longitude: -122.399972, radius: 24140)
            } else {
                print("We already have businesses, not fetching onAppear")
            }
        }
    }
    
    // radius is in meters
    func refreshBusinesses(latitude: Double, longitude: Double, radius: Int) async {
        Task {
            print("fetching new data")
            do {
                let fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: radius)
                nearbyBusinesses = fetchedBusinesses
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
