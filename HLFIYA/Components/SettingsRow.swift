//
//  SettingsRow.swift
//  HLFIYA
//

import SwiftUI

/// A Settings row with a Settings-app style icon, a title, and an optional external-link arrow.
struct SettingsRow: View {
    /// The symbol's plain name, such as "star". It is drawn filled on a square of `iconColor`.
    let iconName: String
    let iconColor: Color
    let title: LocalizedStringResource
    var showsExternalLinkIndicator = false

    var body: some View {
        LabeledContent {
            if showsExternalLinkIndicator {
                ExternalLinkIndicator()
            }
        } label: {
            SettingsLabel(title: title, iconName: iconName, iconColor: iconColor)
        }
        .contentShape(.rect)
    }
}

#Preview {
    Form {
        SettingsRow(
            iconName: "heart",
            iconColor: .fuchsia,
            title: "Rate on the App Store",
            showsExternalLinkIndicator: true
        )
        SettingsRow(iconName: "trash", iconColor: .pink, title: "Delete Data")
    }
}
