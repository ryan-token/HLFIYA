//
//  LocationStatusView.swift
//  HLFIYA
//

import CoreLocation
import SwiftUI

/// Explains whether location access is on, with a button to change it in Settings.
struct LocationStatusView: View {
    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        if let status {
            VStack {
                Text(status.message)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)

                Button(action: openSettings) {
                    Text(status.buttonTitle)
                        .frame(maxWidth: .infinity)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .buttonStyle(.glassProminent)
                .tint(.fuchsia)
                .controlSize(.large)
            }
            .padding(.top)
        }
    }

    private var status: (message: LocalizedStringKey, buttonTitle: LocalizedStringKey)? {
        switch locationViewModel.authorizationStatus {
        case .restricted, .denied:
            ("Location services are disabled", "Allow Location in Settings")
        case .authorizedWhenInUse, .authorizedAlways:
            ("Location services are enabled 🚀", "Change Location Permissions")
        default:
            nil
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}
