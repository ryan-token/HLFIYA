//
//  OtherAppRow.swift
//  HLFIYA
//

import SwiftUI

/// A row promoting another app by the same developer, linking to its App Store page.
///
/// Laid out like an App Store listing: the app's icon beside its name and subtitle. At
/// accessibility text sizes the icon moves above the text, so long names keep the full
/// row width instead of wrapping one word per line.
struct OtherAppRow: View {
    let image: ImageResource
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let url: URL?

    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: openApp) {
            HStack {
                iconAndTextLayout {
                    OtherAppIcon(image: image)

                    VStack(alignment: .leading) {
                        // `Color.primary` and `Color.secondary` rather than `.primary` and
                        // `.secondary`, which inside a button resolve to the tint color.
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(Color.primary)

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    .multilineTextAlignment(.leading)
                    // Starts the row separator under the text, as in the Settings app.
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ExternalLinkIndicator()
            }
            .contentShape(.rect)
        }
        .accessibilityHint("Opens this developer's other app in the App Store.")
    }

    private func openApp() {
        if let url {
            openURL(url)
        }
    }

    /// Side by side normally; stacked at accessibility text sizes.
    private var iconAndTextLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())
    }
}

#Preview {
    Form {
        Section("Try my other apps") {
            OtherAppRow(
                image: .catchUp1024,
                title: "CatchUp: Keep in Touch",
                subtitle: "Personal relationship manager",
                url: nil
            )

            OtherAppRow(
                image: .outrank1024,
                title: "Outrank: CFB Stat Rankings",
                subtitle: "College football team stats",
                url: nil
            )
        }
    }
}

#Preview("Accessibility size") {
    Form {
        OtherAppRow(
            image: .catchUp1024,
            title: "CatchUp: Keep in Touch",
            subtitle: "Personal relationship manager",
            url: nil
        )
    }
    .dynamicTypeSize(.accessibility3)
}
