//
//  SettingsLabel.swift
//  HLFIYA
//

import SwiftUI

/// A Settings title with its icon, drawn the way the Settings app draws its own: a white
/// symbol on a small rounded square of color, beside a title in the body font. Every row
/// uses it, so the icons share one size and the separators line up.
struct SettingsLabel: View {
    let title: LocalizedStringResource

    /// The symbol's plain name, such as "star". It is drawn filled.
    let iconName: String
    let iconColor: Color

    /// The side of the icon's square: 29 points in the Settings app, at the default text
    /// size.
    @ScaledMetric(relativeTo: .body) private var iconSize = 29.0

    /// The share of the square's side that its corners are rounded by.
    private static let cornerRadiusRatio = 0.24

    var body: some View {
        Label {
            // `Color.primary` rather than `.primary`, which inside a button
            // resolves to the tint color.
            Text(title)
                .foregroundStyle(Color.primary)
        } icon: {
            Image(systemName: iconName)
                .symbolVariant(.fill)
                .font(.callout)
                .foregroundStyle(.white)
                .frame(width: iconSize, height: iconSize)
                .background(iconColor, in: .rect(cornerRadius: iconSize * Self.cornerRadiusRatio))
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    List {
        SettingsLabel(title: "Location Permissions", iconName: "location", iconColor: .blue)
        SettingsLabel(title: "Rate on the App Store", iconName: "heart", iconColor: .fuchsia)
        SettingsLabel(title: "Terms & Privacy Policy", iconName: "lock", iconColor: .gray)
    }
}
