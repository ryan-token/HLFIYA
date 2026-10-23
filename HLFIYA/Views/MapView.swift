//
//  MapView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/26/22.
//

import CoreLocation
import MapKit
import SwiftUI

/// Chooses the search area by panning and zooming a map.
struct MapView: View {
    let feed: RestaurantFeed
    let filters: FiltersState

    @State private var position = MapCameraPosition.automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var isShowingRadiusTooLargeAlert = false

    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.dismiss) private var dismiss

    /// The largest radius the app accepts, matching the "less than 25 miles" alert.
    private static let maximumDisplayedRadius = 25.0

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                UserAnnotation()
            }
            .mapControlVisibility(.automatic)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(.circle)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onMapCameraChange(frequency: .continuous) { context in
                visibleRegion = context.region
            }
            .navigationTitle("Choose Location")
            .navigationSubtitle("Radius: \(displayedRadius, format: .number.precision(.fractionLength(1))) Miles")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    LocationAuthorizationButton(resetToCurrentLocation: ResetMapAction(position: $position))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: save)
                }
            }
            .alert("Radius must be less than 25 miles. Please zoom in.", isPresented: $isShowingRadiusTooLargeAlert) {}
        }
        .tint(.fuchsia)
        .onAppear(perform: showSavedSearchArea)
    }

    private var currentRadius: Double {
        visibleRegion.map { Self.radius(forDegrees: $0.span.longitudeDelta) } ?? filters.radius
    }

    /// The radius rounded to one decimal place, exactly as the subtitle shows it.
    private var displayedRadius: Double {
        (currentRadius * 10).rounded() / 10
    }

    /// Shows the area being searched: the saved center, or the person's location
    /// when none is saved, zoomed to the saved radius so saving unchanged keeps it.
    private func showSavedSearchArea() {
        let degrees = Self.degrees(forRadius: filters.radius)
        let center = filters.customCoordinate
            ?? locationViewModel.location?.coordinate
            ?? RestaurantFeed.fallbackCoordinate
        position = .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees)
        ))
    }

    private func save() {
        // Compare against the value people see, so the alert never fires for a
        // radius that reads as less than 25 miles.
        guard displayedRadius < Self.maximumDisplayedRadius else {
            isShowingRadiusTooLargeAlert = true
            return
        }

        let center = visibleRegion?.center ?? filters.customCoordinate ?? locationViewModel.location?.coordinate
        guard let center else {
            dismiss()
            return
        }

        filters.applyLocation(center: center, radius: currentRadius)
        feed.reload(filters: filters, currentLocation: locationViewModel.location)
        dismiss()
    }

    // A degree of latitude is about 69 miles, and the visible span covers the diameter.
    static func degrees(forRadius radius: Double) -> Double {
        (radius / 69) * 2
    }

    static func radius(forDegrees degrees: CLLocationDegrees) -> Double {
        (degrees * 69) / 2
    }
}

#Preview {
    MapView(feed: RestaurantFeed(), filters: FiltersState())
        .environment(LocationViewModel())
}
