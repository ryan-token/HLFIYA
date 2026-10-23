//
//  HotNotOverlay.swift
//  HLFIYA
//

import SwiftUI

/// The "HOT" and "NOT" stamps that fade in as a card is dragged right or left.
struct HotNotOverlay: View {
    /// The card's current horizontal drag distance; positive is rightward.
    let dragDistance: Double

    var body: some View {
        // Layered rather than side by side, so each stamp can use the card's full
        // width and never pushes the other past the edge on narrow cards.
        ZStack {
            SwipeStamp(text: "HOT 🥵", foreground: .fuchsia, background: .white, border: .fuchsia, angle: -25)
                .opacity(dragDistance / 10 - 1)
                .frame(maxWidth: .infinity, alignment: .leading)

            SwipeStamp(text: "NOT 😑", foreground: .black, background: .gray, border: .black, angle: 25)
                .opacity(-dragDistance / 10 - 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.top, 35)
        .padding(.horizontal)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

#Preview {
    HotNotOverlay(dragDistance: 30)
}
