//
//  FilterBar.swift
//  HLFIYA
//

import SwiftUI

/// The large category, price, and location buttons below or beside the deck.
///
/// Kept out of the toolbar so they stay large and at the bottom, including on
/// iPhone Duo, where toolbar items move into the vertical bar at the side.
struct FilterBar: View {
    @Binding var activeSheet: MainSheet?

    var body: some View {
        GlassEffectContainer {
            HStack(alignment: .top) {
                FilterBarButton(
                    title: "Categories",
                    systemImage: "line.3.horizontal.decrease",
                    tint: .pink,
                    sheet: .categories,
                    activeSheet: $activeSheet
                )

                FilterBarButton(
                    title: "Price",
                    systemImage: "dollarsign",
                    tint: .green,
                    sheet: .prices,
                    activeSheet: $activeSheet
                )

                FilterBarButton(
                    title: "Location",
                    systemImage: "map",
                    tint: .blue,
                    sheet: .location,
                    activeSheet: $activeSheet
                )
            }
        }
        .padding(.vertical)
    }
}

/// A round glass button, with its title beneath it, that presents a filter's sheet.
private struct FilterBarButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color
    let sheet: MainSheet
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

            // The button reads the same title to VoiceOver.
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FilterBar(activeSheet: .constant(nil))
}
