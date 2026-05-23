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
            case .notDetermined where locationViewModel.location == nil:
                LocationRequestView()
            default:
                MainView()
            }
        }
        .environment(locationViewModel)
    }
}

#Preview {
    ContentView()
}
