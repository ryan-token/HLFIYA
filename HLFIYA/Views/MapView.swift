//
//  MapView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/26/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334633, longitude: -122.012682),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var isShowingRadiusTooLargeAlert = false
    @State private var initialLatitude: CLLocationDegrees = 0.0
    @State private var initialLongitude: CLLocationDegrees = 0.0
    @State private var initialRadius = 5.0
    @State private var saveTapped = false

    @Binding var nearbyRestaurants: [Business]
    @Binding var remainingRestaurantsInList: Int
    @Binding var currentRestaurantIndex: Int
    @Binding var showRefreshButton: Bool
    @Binding var noResultsFound: Bool
    @Binding var apiError: Bool

    var filters: FiltersState

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Text("Choose Location")
                    .font(.largeTitle)
                    .bold()

                LabeledContent("Radius:") {
                    Text("\(convertDegreesToRadius(degrees: region.span.longitudeDelta), format: .number.precision(.fractionLength(1))) Miles")
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
                        span: MKCoordinateSpan(
                            latitudeDelta: context.region.span.latitudeDelta,
                            longitudeDelta: context.region.span.longitudeDelta
                        )
                    )
                }
            }
            .onChange(of: region.center.latitude) {
                filters.customLatitude = region.center.latitude
            }
            .onChange(of: region.center.longitude) {
                filters.customLongitude = region.center.longitude
            }
            .onChange(of: region.span.longitudeDelta) {
                filters.customRadius = convertDegreesToRadius(degrees: region.span.longitudeDelta)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    locationAuthorizationButton
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
        .onAppear { initialize() }
        .onDisappear {
            if !saveTapped {
                filters.customLatitude = initialLatitude
                filters.customLongitude = initialLongitude
                filters.customRadius = initialRadius
            }

            if filters.customRadius > 24.854847 {
                filters.customRadius = 24.854847
            }
        }
    }

    @ViewBuilder
    private var locationAuthorizationButton: some View {
        switch locationViewModel.authorizationStatus {
        case .notDetermined:
            Button("Request Current Location") {
                locationViewModel.requestPermission()
            }
            .font(.headline)

        case .restricted, .denied:
            Button("Allow Location in Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .font(.headline)

        case .authorizedAlways, .authorizedWhenInUse:
            Button("Reset to Current Location", action: resetToCurrentLocation)
                .font(.headline)

        @unknown default:
            EmptyView()
        }
    }

    private func initialize() {
        initialLatitude = filters.customLatitude
        initialLongitude = filters.customLongitude
        initialRadius = filters.customRadius

        guard let location = locationViewModel.location else { return }
        var latitude = location.coordinate.latitude
        var longitude = location.coordinate.longitude

        // If the custom filter coordinates aren't 0 and aren't your current location, use the custom location.
        if filters.customLatitude != 0.0,
           filters.customLongitude != 0.0,
           filters.customLatitude != latitude || filters.customLongitude != longitude {
            latitude = filters.customLatitude
            longitude = filters.customLongitude
        }

        let degrees = convertRadiusToDegrees(radius: filters.customRadius)
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees)
        )
        position = .region(region)
    }

    private func resetToCurrentLocation() {
        guard let location = locationViewModel.location else { return }
        let degrees = convertRadiusToDegrees(radius: 5.0)
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees)
        )
        position = .region(region)
    }

    private func save() async {
        if filters.customRadius > 24.854847 {
            isShowingRadiusTooLargeAlert.toggle()
            return
        }
        saveTapped = true
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

    // latitudeDelta is the amount of degrees that are visible on the screen. 1 degree ≈ 69 miles.
    private func convertRadiusToDegrees(radius: Double) -> Double {
        (radius / 69) * 2
    }

    private func convertDegreesToRadius(degrees: CLLocationDegrees) -> Double {
        (Double(degrees) * 69) / 2
    }

    private func setState(fetchedBusinesses: [Business]) {
        nearbyRestaurants = fetchedBusinesses
        remainingRestaurantsInList = fetchedBusinesses.count
        currentRestaurantIndex = 0
        showRefreshButton = true
        apiError = false
        noResultsFound = fetchedBusinesses.isEmpty
    }
}
