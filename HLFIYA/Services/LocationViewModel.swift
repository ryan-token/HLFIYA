//
//  LocationViewModel.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import CoreLocation
import MapKit

@Observable
class LocationViewModel: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    var authorizationStatus: CLAuthorizationStatus
    var location: CLLocation?
    var currentPlacemark: MKMapItem?

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

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let first = locations.first
        Task { @MainActor in
            self.location = first
            await self.fetchCountryAndCity(for: first)
        }
    }

    func fetchCountryAndCity(for location: CLLocation?) async {
        guard let location else { return }
        let request = MKReverseGeocodingRequest(location: location)
        do {
            let items = try await request?.mapItems ?? []
            currentPlacemark = items.first
        } catch {
            print("Geocoding error: \(error)")
            currentPlacemark = nil
        }
    }
}
