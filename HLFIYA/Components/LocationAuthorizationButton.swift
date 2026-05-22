//
//  LocationAuthorizationButton.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/21/26.
//

import SwiftUI
import CoreLocation
import UIKit

struct LocationAuthorizationButton: View {
    let authorizationStatus: CLAuthorizationStatus
    let requestPermission: () -> Void
    let resetToCurrentLocation: () -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        switch authorizationStatus {
        case .notDetermined:
            Button("Request Current Location", action: requestPermission)
                .font(.headline)

        case .restricted, .denied:
            Button("Allow Location in Settings", action: openSettings)
                .font(.headline)

        case .authorizedAlways, .authorizedWhenInUse:
            Button("Reset to Current Location", action: resetToCurrentLocation)
                .font(.headline)

        @unknown default:
            EmptyView()
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
