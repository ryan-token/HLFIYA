//
//  BottomBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI

struct BottomBarView: View {
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var apiError: Bool

    @Binding var radiusFilter: Int
    @Binding var categoriesFilter: String
    @Binding var priceFilter: String
    
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        HStack {
            Spacer()
            
            AsyncButton(action: {
                if let location = locationManager.location {
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    
                    do {
                        let fetchedBusinesses = try await BusinessFetcher.getBusinessesNear(latitude: latitude, longitude: longitude, radius: radiusFilter, categories: categoriesFilter, price: priceFilter)
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
                
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(Font.system(size: 50, design: .rounded))
                    .foregroundColor(.yellow)
            }
            
            Spacer()
            
            Button(action: {
                print("Categories filter: \(categoriesFilter)")
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(Font.system(size: 50, design: .rounded))
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            Button(action: {
                print("Price filter: \(priceFilter)")
            }) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(Font.system(size: 50, design: .rounded))
                    .foregroundColor(.green)
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
