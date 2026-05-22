//
//  LocationViewModel.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import CoreLocation
import MapKit

@Observable
final class LocationViewModel: NSObject, CLLocationManagerDelegate {
    var authorizationStatus: CLAuthorizationStatus
    var location: CLLocation?
    var currentPlacemark: MKMapItem?

    private let locationManager: CLLocationManager
    private var geocodeTask: Task<Void, Never>?

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

    // CLLocationManager delivers delegate callbacks on the run loop where the
    // manager was created — the main run loop here — so it's safe to assume
    // MainActor isolation rather than hopping through a fresh Task.
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        MainActor.assumeIsolated {
            self.authorizationStatus = status
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let first = locations.first
        MainActor.assumeIsolated {
            self.location = first
            self.geocodeTask?.cancel()
            self.geocodeTask = Task { [weak self] in
                await self?.fetchCountryAndCity(for: first)
            }
        }
    }

    func fetchCountryAndCity(for location: CLLocation?) async {
        guard let location else { return }
        let request = MKReverseGeocodingRequest(location: location)
        do {
            let items = try await request?.mapItems ?? []
            try Task.checkCancellation()
            currentPlacemark = items.first
        } catch is CancellationError {
            // A newer location update superseded this one; leave currentPlacemark to the winner.
        } catch {
            print("Geocoding error: \(error)")
            currentPlacemark = nil
        }
    }
}
