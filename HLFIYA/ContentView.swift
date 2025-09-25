//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 7/30/22.
//

import SwiftUI

struct ContentView: View {
    @State private var locationViewModel = LocationViewModel()
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        switch locationViewModel.authorizationStatus {
            case .notDetermined:
                if (locationViewModel.location != nil) {
                    MainView()
                        .environment(locationViewModel)
                } else {
                    LocationRequestView()
                        .environment(locationViewModel)
                }
            default:
                MainView()
                    .environment(locationViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
