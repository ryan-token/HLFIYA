//
//  DeckCard.swift
//  HLFIYA
//

import Foundation

/// One restaurant card in the swipe deck, with everything the card needs to draw itself.
nonisolated struct DeckCard: Identifiable, Equatable {
    let business: Business
    /// The restaurant's index in the feed; lower positions sit higher in the stack.
    let position: Int
    /// Whether the card has been swiped off the screen.
    let isSwipedAway: Bool
    /// Whether the card is the one people can currently swipe.
    let isTopCard: Bool
    /// Whether to show the "swipe to skip" hint, before the first swipe.
    let showsSwipeHint: Bool

    var id: String {
        business.id ?? "position-\(position)"
    }
}
