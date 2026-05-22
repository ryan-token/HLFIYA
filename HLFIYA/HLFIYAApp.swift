//
//  HLFIYAApp.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import GoogleMobileAds
import SwiftUI

@main
struct HLFIYAApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .fontDesign(.rounded)
        }
    }
}
