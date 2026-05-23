//
//  MapView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/26/22.
//

import SwiftUI
import MapKit
import CoreLocation

private let defaultRadiusMiles = 5.0
private let maxRadiusMiles = 24.854847

struct MapView: View {
    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var position: MapCameraPosition
    @State private var region: MKCoordinateRegion
    @State private var isShowingRadiusTooLargeAlert = false

    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var noResultsFound: Bool
    @Binding var apiError: Bool

    var filters: FiltersState

    init(
        nearbyRestaurants: Binding<[Business]>,
        remainingRestaurantsInList: Binding<Int>,
        currentRestaurantIndex: Binding<Int>,
        showRefreshButton: Binding<Bool>,
        noResultsFound: Binding<Bool>,
        apiError: Binding<Bool>,
        filters: FiltersState
    ) {
        self._nearbyRestaurants = nearbyRestaurants
        self._remainingRestaurantsInList = remainingRestaurantsInList
        self._currentRestaurantIndex = currentRestaurantIndex
        self._showRefreshButton = showRefreshButton
        self._noResultsFound = noResultsFound
        self._apiError = apiError
        self.filters = filters

        let radius = filters.customRadius > 0 ? filters.customRadius : defaultRadiusMiles
        let degrees = Self.degrees(forRadius: radius)
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: filters.customLatitude,
                longitude: filters.customLongitude
            ),
            span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees)
        )
        let hasCustomLocation = filters.customLatitude != 0.0 || filters.customLongitude != 0.0
        self._region = State(initialValue: initialRegion)
        self._position = State(
            initialValue: hasCustomLocation
                ? .region(initialRegion)
                : .userLocation(followsHeading: false, fallback: .region(initialRegion))
        )
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Choose Location")
                    .font(.largeTitle)
                    .bold()

                LabeledContent("Radius:") {
                    Text("\(Self.radius(forDegrees: region.span.longitudeDelta), format: .number.precision(.fractionLength(1))) Miles")
                        .bold()
                }
                .padding(.horizontal)

                Map(position: $position) {
                    UserAnnotation()
                }
                .mapControlVisibility(.automatic)
                .clipShape(.circle)
                .padding(.horizontal)
                .onMapCameraChange(frequency: .continuous) { context in
                    region = MKCoordinateRegion(
                        center: context.camera.centerCoordinate,
                        span: context.region.span
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    LocationAuthorizationButton(
                        authorizationStatus: locationViewModel.authorizationStatus,
                        requestPermission: locationViewModel.requestPermission,
                        resetToCurrentLocation: resetToCurrentLocation
                    )
                }

                ToolbarItem(placement: .topBarTrailing) {
                    AsyncButton(action: save) {
                        Text("Save").font(.headline)
                    }
                }
            }
            .alert("Radius must be less than 25 miles. Please zoom in.", isPresented: $isShowingRadiusTooLargeAlert) {}
        }
        .tint(.fuchsia)
        .onAppear(perform: centerOnUserLocationIfNeeded)
    }

    private func centerOnUserLocationIfNeeded() {
        // If no custom location is saved yet, center on the user's current location
        // while keeping the radius span chosen at init time.
        guard filters.customLatitude == 0.0, filters.customLongitude == 0.0,
              let location = locationViewModel.location else { return }

        region = MKCoordinateRegion(center: location.coordinate, span: region.span)
        position = .region(region)
    }

    private func resetToCurrentLocation() {
        guard let location = locationViewModel.location else { return }
        let degrees = Self.degrees(forRadius: defaultRadiusMiles)
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees)
        )
        position = .region(region)
    }

    private func save() async {
        let pendingRadius = Self.radius(forDegrees: region.span.longitudeDelta)
        // Compare against the same value the user sees in the UI (rounded to 1 decimal),
        // so the alert never fires for a radius that visually reads as < 25 miles.
        let displayedRadius = (pendingRadius * 10).rounded() / 10
        if displayedRadius >= 25.0 {
            isShowingRadiusTooLargeAlert.toggle()
            return
        }
        filters.customLatitude = region.center.latitude
        filters.customLongitude = region.center.longitude
        // Yelp's API hard-caps at 40,000 m (≈ 24.854847 mi), so clamp before sending.
        filters.customRadius = min(pendingRadius, maxRadiusMiles)
        dismiss()
        let fetchedBusinesses = await MainView.refreshBusinesses(
            customLatitude: filters.customLatitude,
            customLongitude: filters.customLongitude,
            locationViewModel: locationViewModel,
            customRadius: filters.customRadius,
            categories: filters.categories,
            prices: filters.prices,
            onlyGetOpenNow: filters.openNow
        )
        setState(fetchedBusinesses: fetchedBusinesses)
        Utils.writeLocationFilterToCache(
            customLatitude: filters.customLatitude,
            customLongitude: filters.customLongitude,
            customRadius: filters.customRadius
        )
    }

    private func setState(fetchedBusinesses: [Business]) {
        nearbyRestaurants = fetchedBusinesses
        remainingRestaurantsInList = fetchedBusinesses.count
        currentRestaurantIndex = 0
        showRefreshButton = true
        apiError = false
        noResultsFound = fetchedBusinesses.isEmpty
    }

    // latitudeDelta is the amount of degrees visible on the screen. 1 degree ≈ 69 miles.
    private static func degrees(forRadius radius: Double) -> Double {
        (radius / 69) * 2
    }

    private static func radius(forDegrees degrees: CLLocationDegrees) -> Double {
        (degrees * 69) / 2
    }
}
