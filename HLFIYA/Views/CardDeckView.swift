//
//  CardDeckView.swift
//  HLFIYA
//

import SwiftUI

/// The stack of restaurant cards, with the current card on top.
///
/// Only a small window of cards is rendered, so loading 50 restaurants doesn't
/// create 50 image pagers. The deck keeps a card-like aspect ratio rather than
/// stretching across wide displays.
struct CardDeckView: View {
    let feed: RestaurantFeed

    @State private var swipeAwayDistance = 0.0

    var body: some View {
        ZStack {
            ForEach(feed.visibleCards) { card in
                CardView(
                    business: card.business,
                    isSwipedAway: card.isSwipedAway,
                    isTopCard: card.isTopCard,
                    showsSwipeHint: card.showsSwipeHint,
                    swipeAwayDistance: swipeAwayDistance,
                    feed: feed
                )
                .zIndex(-Double(card.position))
            }
        }
        .aspectRatio(3 / 4, contentMode: .fit)
        // A swiped card travels the deck's right edge's distance from the screen's
        // leading edge, plus room for its tilted corners, so it clears the screen
        // even when the deck sits on the right. Measured on the deck, which never
        // moves, because a card's own frame moves as it's dragged.
        .onGeometryChange(for: Double.self) { proxy in
            let frame = proxy.frame(in: .global)
            return frame.maxX + frame.height * 0.15
        } action: { distance in
            swipeAwayDistance = distance
        }
    }
}

#Preview {
    CardDeckView(feed: RestaurantFeed())
}
