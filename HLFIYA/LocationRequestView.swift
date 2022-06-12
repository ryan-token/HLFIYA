//
//  LocationRequestView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import SwiftUI
import CoreLocation

struct LocationRequestView: View {
    private let manager = CLLocationManager()
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("🍑")
                    .font(Font.system(size: 150))
                    .padding(.bottom, 32)
                
                Text("Would you like to *explore* HOT 🥵 LOCAL 📍 FOOD  in your area?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                VStack {
                    Button {
                        LocationManager.shared.requestLocation()
                    } label: {
                        Text("Allow location")
                            .padding()
                            .font(Font.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.black)
                    .clipShape(Capsule())
                    .padding()
                    
                    Button {
                        locationManager.location = CLLocation(latitude: 36.14203247996243, longitude: -95.97570631738338)
                    } label: {
                        Text("Maybe Later")
                            .padding()
                            .font(Font.system(.headline, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    if CLLocationManager.locationServicesEnabled() {
                        switch manager.authorizationStatus {
                        case .notDetermined:
                            Text("")
                        case .restricted, .denied:
                            Text("Location services are disabled. Enable location services by going to the Settings app -> HLFIYA -> Location -> and selecting 'While Using the App'")
                                .foregroundColor(.gray)
                                .font(Font.system(.body, design: .rounded))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        case .authorizedAlways, .authorizedWhenInUse:
                            Text("")
                        @unknown default:
                            Text("")
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .foregroundColor(.red)
        }
    }
}

struct LocationRequestView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRequestView()
    }
}
