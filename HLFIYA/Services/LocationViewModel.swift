//
//  LocationViewModel.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import CoreLocation

@Observable
final class LocationViewModel: NSObject, CLLocationManagerDelegate {
    private(set) var authorizationStatus: CLAuthorizationStatus
    var location: CLLocation?

    private let locationManager: CLLocationManager
    private var locationUpdatesTask: Task<Void, Never>?

    // Must be initialised on the main run loop. `CLLocationManager` binds its
    // delegate callbacks to the run loop that's active at init time, and the
    // delegate methods below use `MainActor.assumeIsolated` on that promise.
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus

        super.init()
        locationManager.delegate = self
        // Assigning the delegate triggers `locationManagerDidChangeAuthorization` immediately,
        // which is what kicks off the live-updates stream once the user is authorized.
    }

    isolated deinit {
        locationUpdatesTask?.cancel()
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
            if status.isAuthorizedForLocation {
                self.startLocationUpdates()
            } else {
                self.locationUpdatesTask?.cancel()
                self.locationUpdatesTask = nil
            }
        }
    }

    private func startLocationUpdates() {
        locationUpdatesTask?.cancel()
        locationUpdatesTask = Task { [weak self] in
            do {
                for try await update in CLLocationUpdate.liveUpdates() {
                    guard let self else { return }
                    if let newLocation = update.location {
                        self.location = newLocation
                    }
                }
            } catch {
                // Stream ended (authorization revoked or system error). The
                // delegate callback above is responsible for restarting it.
            }
        }
    }
}

private extension CLAuthorizationStatus {
    var isAuthorizedForLocation: Bool {
        self == .authorizedWhenInUse || self == .authorizedAlways
    }
}
