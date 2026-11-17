//
//  FeedLayout.swift
//  HLFIYA
//

import SwiftUI

/// Arranges the filter summary, the swipe deck, and the filter buttons in whichever way
/// gives the deck's cards the most room.
///
/// Stacked, the summary sits above the deck and the buttons below it. Side by side, the
/// summary and buttons share a column beside the deck. The layout measures both and keeps
/// the arrangement with the larger card, so a tall phone stacks, a landscape phone sits
/// side by side, and in-between shapes, such as iPhone Duo's outer display with a banner
/// ad, take whichever fits better. Because it's one layout, switching arrangements keeps
/// the deck's identity and state.
///
/// Expects exactly three subviews: the summary, the deck, and the buttons, in that order.
/// `FeedArrangement` does the arithmetic, so it can be tested without views.
struct FeedLayout: Layout {
    /// The deck's cards' width divided by their height.
    let cardAspectRatio: Double

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 3 else {
            assertionFailure("FeedLayout expects a summary, a deck, and buttons; got \(subviews.count) subviews.")
            return
        }
        let summary = subviews[0]
        let deck = subviews[1]
        let buttons = subviews[2]

        let arrangement = FeedArrangement(
            cardAspectRatio: cardAspectRatio,
            verticalSpacing: summary.spacing.distance(to: deck.spacing, along: .vertical),
            horizontalSpacing: summary.spacing.distance(to: deck.spacing, along: .horizontal)
        )
        let frames = arrangement.frames(
            in: bounds,
            summarySize: { summary.sizeThatFits($0) },
            buttonsSize: { buttons.sizeThatFits($0) }
        )

        // Centered, so a part narrower than its space, like the summary, sits in the middle.
        for (subview, frame) in [(summary, frames.summary), (deck, frames.deck), (buttons, frames.buttons)] {
            let center = CGPoint(x: frame.midX, y: frame.midY)
            subview.place(at: center, anchor: .center, proposal: ProposedViewSize(frame.size))
        }
    }
}
