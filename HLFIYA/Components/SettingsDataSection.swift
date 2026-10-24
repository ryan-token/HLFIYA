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
                SettingsRow(iconName: "arrow.left.arrow.right.square.fill", iconColor: .orange, title: "Swipes")
            }

            NavigationLink(value: SettingsDestination.deleteData) {
                SettingsRow(iconName: "trash.square.fill", iconColor: .pink, title: "Delete Data")
            }
        }
    }
}
