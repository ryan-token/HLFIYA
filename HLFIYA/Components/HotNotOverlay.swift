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
        HStack {
            SwipeStamp(text: "HOT 🥵", foreground: .fuchsia, background: .white, border: .fuchsia, angle: -25)
                .opacity(dragDistance / 10 - 1)

            Spacer()

            SwipeStamp(text: "NOT 😑", foreground: .black, background: .gray, border: .black, angle: 25)
                .opacity(-dragDistance / 10 - 1)
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
