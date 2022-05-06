//
//  RadiusSlider.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/30/22.
//

import SwiftUI

struct RadiusSlider: View {
    @Binding var radiusFilter: Double
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var apiError: Bool
    
    var categoriesFilter: Set<String>
    var priceFilter: String
    
    @ObservedObject var locationManager = LocationManager.shared
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                HStack {
                    Text("Show food within a")
                    Text("\(String(format:"%.1f", radiusFilter))")
                        .bold()
                    Text("mile radius")
                }
                
                Slider(value: $radiusFilter, in: 1...25)
                    .padding()
                
                Spacer()
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AsyncButton(action: {
                        dismiss()
                        await refreshBusinesses()
                    }) {
                        Text("Close")
                    }
                }
            }
        }
    }
    
    func refreshBusinesses() async {
        if let location = locationManager.location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            do {
                let fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: Utils.convertMilesToMeters(miles: radiusFilter), categories: categoriesFilter, price: priceFilter)
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

//struct RadiusSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        RadiusSlider()
//    }
//}
