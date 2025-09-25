//
//  LocationManager.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import CoreLocation

@Observable
class LocationViewModel: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    var authorizationStatus: CLAuthorizationStatus
    var location: CLLocation?
    var currentPlacemark: CLPlacemark?
    
    private let locationManager: CLLocationManager

    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first

        Task { @MainActor in
            await fetchCountryAndCity(for: locations.first)
        }
    }

    @MainActor
    func fetchCountryAndCity(for location: CLLocation?) async {
        guard let location = location else { return }
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            currentPlacemark = placemarks.first
        } catch {
            print("Geocoding error: \(error)")
            currentPlacemark = nil
        }
    }
}
