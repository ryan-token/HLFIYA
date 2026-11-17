//
//  HotLocalFoodTitle.swift
//  HLFIYA
//

import SwiftUI

/// The neon "Hot Local Food" wordmark, styled after the app icon, whose words slide in
/// and flicker on one at a time.
///
/// The words share one canvas and are already placed within the wordmark, so stacking them
/// assembles it at any size.
struct HotLocalFoodTitle: View {
    let showsHot: Bool
    let showsLocal: Bool
    let showsFood: Bool

    var body: some View {
        ZStack {
            TitleWord(word: .hot, isVisible: showsHot)
            TitleWord(word: .local, isVisible: showsLocal)
            TitleWord(word: .food, isVisible: showsFood)
        }
        .aspectRatio(WordmarkLetteringData.aspectRatio, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hot Local Food")
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    HotLocalFoodTitle(showsHot: true, showsLocal: true, showsFood: true)
}
