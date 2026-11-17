//
//  SettingsDataSection.swift
//  HLFIYA
//

import SwiftUI

/// Links to swipe statistics and data deletion.
struct SettingsDataSection: View {
    var body: some View {
        Section("Data") {
            NavigationLink(value: SettingsDestination.swipeStats) {
                SettingsRow(iconName: "arrow.left.arrow.right", iconColor: .orange, title: "Swipes")
            }

            NavigationLink(value: SettingsDestination.deleteData) {
                SettingsRow(iconName: "trash", iconColor: .pink, title: "Delete Data")
            }
        }
    }
}
