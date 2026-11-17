//
//  OtherAppIcon.swift
//  HLFIYA
//

import SwiftUI

/// Another app's icon, drawn the way the App Store lists it: a continuous rounded square
/// with a hairline edge, so light icons hold their shape.
struct OtherAppIcon: View {
    let image: ImageResource

    /// The icon's side at the default text size, close to the App Store's list icons.
    @ScaledMetric(relativeTo: .body) private var iconSize = 48.0

    /// Stops the icon growing past a comfortable size at the largest text sizes.
    private static let maximumIconSize = 80.0

    /// The share of the icon's side that its corners are rounded by, matching app icons.
    private static let cornerRadiusRatio = 0.225

    var body: some View {
        let side = min(iconSize, Self.maximumIconSize)
        let cornerRadius = side * Self.cornerRadiusRatio

        Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: side, height: side)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.separator, lineWidth: 0.5)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        OtherAppIcon(image: .catchUp1024)
        OtherAppIcon(image: .outrank1024)
    }
}
