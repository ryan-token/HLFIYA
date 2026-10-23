//
//  CardStatusBadge.swift
//  HLFIYA
//

import SwiftUI

/// A capsule at the top of a card with the swipe hint or a photo-loading error.
struct CardStatusBadge: View {
    let showsSwipeHint: Bool
    let photosFailedToLoad: Bool

    var body: some View {
        VStack {
            if showsSwipeHint {
                Text("Swipe ← to skip, swipe → for details")
                    .accessibilityHidden(true)
            }

            if photosFailedToLoad {
                Text("😕 Couldn't load more photos")
            }
        }
        .font(.footnote)
        .foregroundStyle(.white)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.black.opacity(0.4), in: .capsule)
        .opacity(showsSwipeHint || photosFailedToLoad ? 1 : 0)
        .padding(.top)
        .allowsHitTesting(false)
    }
}

#Preview {
    CardStatusBadge(showsSwipeHint: true, photosFailedToLoad: true)
        .padding()
        .background(.gray)
}
