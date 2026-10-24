//
//  LocationAuthorizationButton.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/26/22.
//

import CoreLocation
import SwiftUI

/// Requests location access, links to Settings when it's denied, or recenters
/// the map once it's granted.
struct LocationAuthorizationButton: View {
    let resetToCurrentLocation: ResetMapAction

    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        switch locationViewModel.authorizationStatus {
        case .notDetermined:
            Button("Request Current Location", systemImage: "location") {
                locationViewModel.requestPermission()
            }

        case .restricted, .denied:
            Button("Allow Location in Settings", systemImage: "location.slash", action: openSettings)

        case .authorizedAlways, .authorizedWhenInUse:
            Button("Reset to Current Location", systemImage: "location.fill") {
                resetToCurrentLocation(location: locationViewModel.location)
            }

        @unknown default:
            EmptyView()
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
