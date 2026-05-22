//
//  LocationRequestView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/26/22.
//

import SwiftUI
import CoreLocation

struct LocationRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(LocationViewModel.self) private var locationViewModel
    @AppStorage("userHasOpenedAppBefore") private var userHasOpenedAppBefore = false

    @State private var showGetReady = false
    @State private var showHot = false
    @State private var showLocal = false
    @State private var showFood = false
    @State private var showAllowLocation = false
    @State private var showMaybeLater = false

    var body: some View {
        VStack {
            Spacer()

            if showGetReady {
                Text("Get ready for some")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }

            Spacer()

            HotLocalFoodTitle(showHot: showHot, showLocal: showLocal, showFood: showFood)

            Spacer()

            VStack {
                if showAllowLocation && !isLocationDetermined {
                    Button {
                        locationViewModel.requestPermission()
                    } label: {
                        Text("Allow Location")
                            .padding()
                            .font(.headline)
                            .foregroundStyle(.background)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.primary)
                    .clipShape(.capsule)
                    .padding()
                    .animation(.default, value: showAllowLocation)
                }

                if showMaybeLater && !isLocationDetermined {
                    Button {
                        locationViewModel.location = CLLocation(latitude: 37.334633, longitude: -122.012682)
                        dismiss()
                    } label: {
                        Text("Maybe Later")
                            .padding()
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .animation(.default, value: showMaybeLater)
                    }
                }

                LocationStatusView()
            }
        }
        .foregroundStyle(.fuchsia)
        .task {
            await animateIntro()
        }
    }

    private var isLocationDetermined: Bool {
        let status = locationViewModel.authorizationStatus
        return status == .denied || status == .authorizedWhenInUse
    }

    private func animateIntro() async {
        if userHasOpenedAppBefore {
            showGetReady = true
            showHot = true
            showLocal = true
            showFood = true
            showAllowLocation = true
            showMaybeLater = true
            return
        }

        try? await Task.sleep(for: .seconds(1))
        withAnimation { showGetReady = true }

        try? await Task.sleep(for: .seconds(2))
        withAnimation { showHot = true }

        try? await Task.sleep(for: .seconds(1))
        withAnimation { showLocal = true }

        try? await Task.sleep(for: .seconds(1))
        withAnimation { showFood = true }

        try? await Task.sleep(for: .seconds(2))
        withAnimation {
            showAllowLocation = true
            showMaybeLater = true
        }
    }
}

private struct HotLocalFoodTitle: View {
    let showHot: Bool
    let showLocal: Bool
    let showFood: Bool

    var body: some View {
        VStack(spacing: -50) {
            if showHot {
                Image("hot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 100)
                    .padding(.trailing, 26)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }

            if showLocal {
                Image("local")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 100)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }

            Spacer()
                .frame(height: 53)

            if showFood {
                Image("food")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 100)
                    .padding(.leading, 15)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
            }
        }
    }
}

private struct LocationStatusView: View {
    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        switch locationViewModel.authorizationStatus {
        case .notDetermined:
            EmptyView()

        case .restricted, .denied:
            statusButton(
                message: "Location services are disabled",
                buttonTitle: "Allow Location in Settings"
            )

        case .authorizedWhenInUse, .authorizedAlways:
            statusButton(
                message: "Location services are enabled 🚀",
                buttonTitle: "Change Location Permissions"
            )

        @unknown default:
            EmptyView()
        }
    }

    private func statusButton(message: String, buttonTitle: String) -> some View {
        VStack(spacing: 0) {
            Text(message)
                .foregroundStyle(.fuchsia)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            } label: {
                Text(buttonTitle)
                    .padding()
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .background(.fuchsia)
            .clipShape(.capsule)
            .padding()
        }
        .padding(.top, 30)
    }
}

#Preview {
    LocationRequestView()
        .environment(LocationViewModel())
}
