//
//  MapView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/26/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @ObservedObject var filters: FiltersState
    @ObservedObject var locationManager = LocationManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Set Custom Location")
                    .font(.largeTitle)
                Text("The map area showing here will be ")
                Map(coordinateRegion: $region)
                    .frame(width: 400, height: 300)
            }
            
            .onAppear {
                if let location = locationManager.location {
                    var latitude = location.coordinate.latitude
                    var longitude = location.coordinate.longitude
                    
                    if ((filters.customLatitude != 0.000000 && filters.customLongitude != 0.000000) && (filters.customLatitude != latitude || filters.customLongitude != longitude)) {
                        latitude = filters.customLatitude
                        longitude = filters.customLongitude
                    }
                    
                    let degrees = degreesFromRadius(radius: filters.customRadius)
                    print("degrees: \(degrees)")
                    
                    region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees))
                }
            }
        
            .onChange(of: region.center.latitude) { newLatitude in
                filters.customLatitude = newLatitude
            }
            
            .onChange(of: region.center.longitude) { newLongitude in
                filters.customLongitude = newLongitude
            }
            
            .onChange(of: region.span.latitudeDelta) { newLatitudeDelta in
                filters.customRadius = radiusFromDegrees(degrees: newLatitudeDelta)
            }
        
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if let location = locationManager.location {
                            let latitude = location.coordinate.latitude
                            let longitude = location.coordinate.longitude
                            
                            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                        }
                    }) {
                        Text("Reset")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    AsyncButton(action: {
                        dismiss()
                    }) {
                        Text("Close")
                    }
                }
            }
        }
    }
}

// latitudeDelta is the amount of degrees that are visible on the screen. 1 degree is always equal to approx. 69 miles, so you can calculate the diameter of the currently visible area in miles with this diameter = latitudeDelta * 69. This is assuming the screen is in portrait mode and, therefore, latitudeDelta is the larger value. If not, use longitudeDelta instead. I hope I understood your question correctly and this is helpful.
func degreesFromRadius(radius: Double) -> Double {
    let degreesFromRadius = radius/69
    return degreesFromRadius
}

func radiusFromDegrees(degrees: CLLocationDegrees) -> Double {
    let radiusFromDegrees = Double(degrees)*69
    return radiusFromDegrees
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
