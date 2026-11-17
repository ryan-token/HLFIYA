//
//  FilterBarButton.swift
//  HLFIYA
//

import SwiftUI

/// A round glass button, optionally with its title beneath it, that presents a filter's sheet.
struct FilterBarButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color
    let sheet: MainSheet
    var showsTitle = true
    @Binding var activeSheet: MainSheet?

    /// Keeps every circle the same size, whatever its symbol's width.
    @ScaledMetric(relativeTo: .title2) private var iconSize = 36.0

    var body: some View {
        VStack {
            Button {
                activeSheet = sheet
            } label: {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: iconSize, height: iconSize)
            }
            .accessibilityLabel(Text(title))
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(tint)

            if showsTitle {
                // The button reads the same title to VoiceOver.
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    // Never truncated or wrapped: when the titles don't fit, the row
                    // reports it, and the bar switches to the buttons without titles.
                    .fixedSize()
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FilterBarButton(
        title: "Categories",
        systemImage: "line.3.horizontal.decrease",
        tint: .pink,
        sheet: .categories,
        activeSheet: .constant(nil)
    )
}
