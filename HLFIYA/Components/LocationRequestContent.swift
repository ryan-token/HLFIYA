//
//  LocationRequestContent.swift
//  HLFIYA
//

import CoreLocation
import SwiftUI

/// The wordmark and location buttons of the intro, revealed step by step.
struct LocationRequestContent: View {
    let introStep: IntroStep

    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    @Environment(LocationViewModel.self) private var locationViewModel

    /// Keeps the buttons a comfortable width on wide displays such as iPhone Duo's inner display.
    @ScaledMetric(relativeTo: .headline) private var maximumButtonWidth = 440.0

    var body: some View {
        // Every element keeps its place while hidden, so the wordmark doesn't
        // shift as each step of the intro appears.
        VStack {
            VStack {
                Text("Get ready for some")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .opacity(introStep >= .getReady ? 1 : 0)

                // Scales to the remaining space, so everything fits without scrolling.
                HotLocalFoodTitle(
                    showsHot: introStep >= .hot,
                    showsLocal: introStep >= .local,
                    showsFood: introStep >= .food
                )
                .padding()
            }
            .frame(maxHeight: .infinity)

            VStack {
                if !isLocationDetermined {
                    Button {
                        locationViewModel.requestPermission()
                    } label: {
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
        // The status bar can sit at the side on iPhone Duo, leaving no top inset.
        .padding()
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

        // When pushed from Settings, also go back.
        if isPresented {
            dismiss()
        }
    }
}

#Preview {
    LocationRequestContent(introStep: .buttons)
        .foregroundStyle(.fuchsia)
        .environment(LocationViewModel())
}
