//
//  MainToolbar.swift
//  HLFIYA
//

import SwiftUI

/// The main screen's toolbar: settings and lists.
///
/// Each item has a title and a symbol, so on iPhone Duo the system can place it in
/// the vertical bar and list it by name if it moves into the overflow menu.
struct MainToolbar: ToolbarContent {
    @Binding var activeSheet: MainSheet?

    var body: some ToolbarContent {
        // Neither item has a semantic role, so they keep their familiar sides.
        ToolbarItem(placement: .topBarLeading) {
            Button("Settings", systemImage: "gear") {
                activeSheet = .settings
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Lists", systemImage: "list.bullet") {
                activeSheet = .lists
            }
        }
    }
}
