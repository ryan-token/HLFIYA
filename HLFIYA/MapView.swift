//
//  MapView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/26/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State var tracking:MapUserTrackingMode = .follow
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @Binding var nearbyBusinesses: [Business]
    @Binding var remainingBusinessesInList: Int
    @Binding var currentBusinessIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var apiError: Bool
    
    @ObservedObject var filters: FiltersState
    @ObservedObject var locationManager = LocationManager.shared
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text("Choose Location")
                    .font(Font.system(.largeTitle, design: .rounded))
                    .bold()
                
                HStack {
                    Text("Radius:")
                        .foregroundColor(.gray)
                    Text("\(String(format:"%.1f", convertDegreesToRadius(degrees: region.span.longitudeDelta))) Miles")
                        .bold()
                }
                .font(Font.system(.body, design: .rounded))
                
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $tracking)
                    .clipShape(Circle())
                    .padding(.horizontal)
            }
            
            .onAppear {
                if let location = locationManager.location {
                    var latitude = location.coordinate.latitude
                    var longitude = location.coordinate.longitude
                    
                    if ((filters.customLatitude != 0.000000 && filters.customLongitude != 0.000000) && (filters.customLatitude != latitude || filters.customLongitude != longitude)) {
                        latitude = filters.customLatitude
                        longitude = filters.customLongitude
                    }
                    
                    let degrees = convertRadiusToDegrees(radius: filters.customRadius)
                    
                    region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees))
                }
            }
        
            .onChange(of: region.center.latitude) { newLatitude in
                filters.customLatitude = newLatitude
            }
            
            .onChange(of: region.center.longitude) { newLongitude in
                filters.customLongitude = newLongitude
            }
            
            .onChange(of: region.span.longitudeDelta) { newLongitudeDelta in
                filters.customRadius = convertDegreesToRadius(degrees: newLongitudeDelta)
            }
        
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if let location = locationManager.location {
                            let latitude = location.coordinate.latitude
                            let longitude = location.coordinate.longitude
                            
                            let degrees = convertRadiusToDegrees(radius: 5.0)
                            
                            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees))
                        }
                    }) {
                        Text("Reset")
                            .font(Font.system(.body, design: .rounded))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    AsyncButton(action: {
                        dismiss()
                        let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationManager: locationManager, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
                        setState(fetchedBusinesses: fetchedBusinesses)
                    }) {
                        Text("Save")
                            .font(Font.system(.body, design: .rounded))
                    }
                }
            }
        }
    }
    
    // latitudeDelta is the amount of degrees that are visible on the screen. 1 degree is equal to ~69 miles
    func convertRadiusToDegrees(radius: Double) -> Double {
        return radius/69
    }

    func convertDegreesToRadius(degrees: CLLocationDegrees) -> Double {
        return Double(degrees)*69
    }

    func setState(fetchedBusinesses: [Business]) {
        nearbyBusinesses = fetchedBusinesses
        remainingBusinessesInList = fetchedBusinesses.count
        currentBusinessIndex = 0
        showRefreshButton = true
        apiError = false
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
