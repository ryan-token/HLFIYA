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

    var body: some View {
        ZStack {
            ForEach(feed.visibleCards) { card in
                CardView(
                    business: card.business,
                    isSwipedAway: card.isSwipedAway,
                    isTopCard: card.isTopCard,
                    showsSwipeHint: card.showsSwipeHint,
                    feed: feed
                )
                .zIndex(-Double(card.position))
            }
        }
        .aspectRatio(3 / 4, contentMode: .fit)
    }
}

#Preview {
    CardDeckView(feed: RestaurantFeed())
}
