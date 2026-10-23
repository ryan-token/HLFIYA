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
    #if DEBUG
    let persistenceController = ScreenshotMode.isEnabled
        ? ScreenshotMode.makePersistenceController()
        : PersistenceController.shared
    #else
    let persistenceController = PersistenceController.shared
    #endif

    init() {
        #if DEBUG
        // Screenshots show no ads.
        guard !ScreenshotMode.isEnabled else { return }
        #endif
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
