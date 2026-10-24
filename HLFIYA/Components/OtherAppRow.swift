//
//  OtherAppRow.swift
//  HLFIYA
//

import SwiftUI

/// A row promoting another app by the same developer, linking to its App Store page.
struct OtherAppRow: View {
    let image: ImageResource
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let url: URL?

    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .headline) private var iconSize = 60.0

    var body: some View {
        Button {
            if let url {
                openURL(url)
            }
        } label: {
            Label {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .clipShape(.rect(cornerRadius: iconSize / 5.5))
            }
        }
        .accessibilityHint("Opens this developer's other app in the App Store.")
    }
}

#Preview {
    List {
        OtherAppRow(
            image: .catchUp1024,
            title: "CatchUp: Keep in Touch",
            subtitle: "Personal relationship manager",
            url: nil
        )
    }
}
