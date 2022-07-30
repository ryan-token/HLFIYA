//
//  ContentView.swift
//  HLFIYA
//
//  Created by Ryan Token on 7/30/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationViewModel = LocationViewModel()
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        switch locationViewModel.authorizationStatus {
            case .notDetermined:
                if (locationViewModel.location != nil) {
                    MainView()
                        .environmentObject(locationViewModel)
                } else {
                    LocationRequestView()
                        .environmentObject(locationViewModel)
                }
            default:
                MainView()
                    .environmentObject(locationViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
