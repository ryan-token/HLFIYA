//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 7/30/22.
//

import SwiftUI

struct ContentView: View {
    @State private var locationViewModel = LocationViewModel()

    var body: some View {
        Group {
            switch locationViewModel.authorizationStatus {
            case .notDetermined where locationViewModel.location == nil && !Self.skipsLocationRequest:
                LocationRequestView()
            default:
                MainView()
            }
        }
        .environment(locationViewModel)
    }

    /// Screenshot mode searches its own sample area, so it never asks for location.
    private static var skipsLocationRequest: Bool {
        #if DEBUG
        ScreenshotMode.isEnabled
        #else
        false
        #endif
    }
}

#Preview {
    ContentView()
}
