//
//  SettingsRow.swift
//  HLFIYA
//

import SwiftUI

/// A Settings row with a colored icon, a title, and an optional external-link arrow.
struct SettingsRow: View {
    let iconName: String
    let iconColor: Color
    let title: LocalizedStringResource
    var showsExternalLinkIndicator = false

    var body: some View {
        LabeledContent {
            if showsExternalLinkIndicator {
                Image(systemName: "arrow.up.forward")
                    .foregroundStyle(.tertiary)
                    .font(.callout)
                    .accessibilityHidden(true)
            }
        } label: {
            Label {
                // `Color.primary` rather than `.primary`, which inside a button
                // resolves to the tint color.
                Text(title)
                    .foregroundStyle(Color.primary)
            } icon: {
                Image(systemName: iconName)
                    .font(.title)
                    .foregroundStyle(iconColor)
            }
        }
        .contentShape(.rect)
    }
}

#Preview {
    Form {
        SettingsRow(
            iconName: "heart.square.fill",
            iconColor: .pink,
            title: "Rate on the App Store",
            showsExternalLinkIndicator: true
        )
    }
}
