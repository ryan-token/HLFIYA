//
//  IntroLocationButtons.swift
//  HLFIYA
//

import CoreLocation
import SwiftUI

/// The intro's location buttons, or the current permission status once it's been decided.
struct IntroLocationButtons: View {
    let introStep: IntroStep

    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    @Environment(LocationViewModel.self) private var locationViewModel

    /// Keeps the buttons a comfortable width on wide displays such as iPhone Duo's inner display.
    @ScaledMetric(relativeTo: .headline) private var maximumButtonWidth = 440.0

    var body: some View {
        VStack {
            if !isLocationDetermined {
                Button(action: locationViewModel.requestPermission) {
                    Text("Allow Location")
                        .frame(maxWidth: .infinity)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .buttonStyle(.glassProminent)
                .tint(.fuchsia)
                .controlSize(.large)

                Button("Maybe Later", action: skipLocation)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            LocationStatusView()
        }
        .frame(maxWidth: maximumButtonWidth)
        .opacity(introStep >= .buttons ? 1 : 0)
        .allowsHitTesting(introStep >= .buttons)
        .accessibilityHidden(introStep < .buttons)
    }

    private var isLocationDetermined: Bool {
        locationViewModel.authorizationStatus != .notDetermined
    }

    private func skipLocation() {
        // Setting a location moves the first-launch flow on to the main screen.
        locationViewModel.location = CLLocation(
            latitude: RestaurantFeed.fallbackCoordinate.latitude,
            longitude: RestaurantFeed.fallbackCoordinate.longitude
        )

        // Only when pushed from Settings is there a presentation to end; on first launch
        // the intro is the scene's content, and the location above replaces it.
        if isPresented {
            dismiss()
        }
    }
}

#Preview {
    IntroLocationButtons(introStep: .buttons)
        .padding()
        .environment(LocationViewModel())
}
