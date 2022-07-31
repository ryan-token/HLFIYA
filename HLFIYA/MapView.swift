//
//  MapView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/26/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State var tracking:MapUserTrackingMode = .follow
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @State private var isShowingRadiusTooLargeAlert = false
    
    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var noResultsFound: Bool
    @Binding var apiError: Bool
    
    @ObservedObject var filters: FiltersState
    @EnvironmentObject var locationViewModel: LocationViewModel
    
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
                if let location = locationViewModel.location {
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
            
            .onDisappear {
                if filters.customRadius > 24.854847 {
                    filters.customRadius = 24.854847
                }
            }
        
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    switch locationViewModel.authorizationStatus{
                    case .notDetermined:
                        Button(action: {
                            locationViewModel.requestPermission()
                        }) {
                            Text("Request Current Location")
                                .font(Font.system(.headline, design: .rounded))
                        }
                    case .restricted, .denied:
                        Button(action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }) {
                            Text("Allow Location in Settings")
                                .font(Font.system(.headline, design: .rounded))
                        }
                        
                    case .authorizedAlways, .authorizedWhenInUse:
                        Button(action: {
                            if let location = locationViewModel.location {
                                let latitude = location.coordinate.latitude
                                let longitude = location.coordinate.longitude
                                
                                let degrees = convertRadiusToDegrees(radius: 5.0)
                                
                                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees))
                            }
                        }) {
                            Text("Reset to Current Location")
                                .font(Font.system(.headline, design: .rounded))
                        }
                    @unknown default:
                        Text("")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    AsyncButton(action: {
                        if (filters.customRadius > 24.854847) {
                            isShowingRadiusTooLargeAlert.toggle()
                        } else {
                            dismiss()
                            let fetchedBusinesses = await MainView.refreshBusinesses(customLatitude: filters.customLatitude, customLongitude: filters.customLongitude, locationViewModel: locationViewModel, customRadius: filters.customRadius, categories: filters.categories, prices: filters.prices)
                            setState(fetchedBusinesses: fetchedBusinesses)
                        }
                    }) {
                        Text("Save")
                            .font(Font.system(.headline, design: .rounded))
                    }
                }
            }
            
            .alert("Radius must be less than 25 miles. Please zoom in.", isPresented: $isShowingRadiusTooLargeAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(Color(UIColor(named: "fuchsia")!))
    }
    
    // latitudeDelta is the amount of degrees that are visible on the screen. 1 degree is equal to ~69 miles
    func convertRadiusToDegrees(radius: Double) -> Double {
        return radius/69
    }

    func convertDegreesToRadius(degrees: CLLocationDegrees) -> Double {
        return Double(degrees)*69
    }

    func setState(fetchedBusinesses: [Business]) {
        nearbyRestaurants = fetchedBusinesses
        remainingRestaurantsInList = fetchedBusinesses.count
        currentRestaurantIndex = 0
        showRefreshButton = true
        apiError = false
        if fetchedBusinesses.isEmpty {
            noResultsFound = true
        } else {
            noResultsFound = false
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
