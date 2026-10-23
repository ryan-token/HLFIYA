//
//  HotLocalFoodTitle.swift
//  HLFIYA
//

import SwiftUI

/// The "Hot Local Food" wordmark, whose words slide in one at a time.
///
/// Each word's image is a layer on the same canvas, already placed within the
/// wordmark, so stacking them assembles it at any size.
struct HotLocalFoodTitle: View {
    let showsHot: Bool
    let showsLocal: Bool
    let showsFood: Bool

    var body: some View {
        ZStack {
            TitleWord(image: .hot, isVisible: showsHot, insertionEdge: .leading)
            TitleWord(image: .local, isVisible: showsLocal, insertionEdge: .trailing)
            TitleWord(image: .food, isVisible: showsFood, insertionEdge: .bottom)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hot Local Food")
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    HotLocalFoodTitle(showsHot: true, showsLocal: true, showsFood: true)
}
