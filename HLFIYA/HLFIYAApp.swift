//
//  HLFIYAApp.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import SwiftUI

@main
struct HLFIYAApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
