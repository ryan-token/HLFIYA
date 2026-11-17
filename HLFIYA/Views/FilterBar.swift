//
//  FilterBar.swift
//  HLFIYA
//

import SwiftUI

/// The large category, price, and location buttons below or beside the deck.
///
/// Kept out of the toolbar so they stay large and at the bottom, including on
/// iPhone Duo, where toolbar items move into the vertical bar at the side. When the
/// titles under the buttons would have to break mid-word, the buttons show without
/// them; VoiceOver still reads each button's title.
struct FilterBar: View {
    @Binding var activeSheet: MainSheet?

    var body: some View {
        GlassEffectContainer {
            ViewThatFits(in: .horizontal) {
                FilterBarButtonRow(showsTitles: true, activeSheet: $activeSheet)
                FilterBarButtonRow(showsTitles: false, activeSheet: $activeSheet)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    FilterBar(activeSheet: .constant(nil))
}
