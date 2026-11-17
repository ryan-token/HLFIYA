//
//  IntroWordmark.swift
//  HLFIYA
//

import SwiftUI

/// "Get ready for some Hot Local Food", revealed step by step as the intro plays.
struct IntroWordmark: View {
    let introStep: IntroStep

    var body: some View {
        // Every element keeps its place while hidden, so the wordmark doesn't
        // shift as each step of the intro appears.
        VStack {
            GetReadyTitle(isVisible: introStep >= .getReady)

            // Scales to the remaining space, so everything fits without scrolling, but stays
            // narrower than the screen to leave the sign some breathing room.
            HotLocalFoodTitle(
                showsHot: introStep >= .hot,
                showsLocal: introStep >= .local,
                showsFood: introStep >= .food
            )
            .containerRelativeFrame(.horizontal) { width, _ in
                width * 0.7
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    IntroWordmark(introStep: .food)
        .padding()
}
