//
//  FeedArrangement.swift
//  HLFIYA
//

import SwiftUI

/// Works out where `FeedLayout` puts the summary, the deck, and the buttons.
///
/// Takes the summary's and buttons' sizes as functions of what they're offered, rather than
/// the views themselves, so tests can supply sizes directly.
nonisolated struct FeedArrangement {
    /// Where each part goes.
    struct Frames: Equatable {
        var summary: CGRect
        var deck: CGRect
        var buttons: CGRect
    }

    /// The deck's cards' width divided by their height.
    var cardAspectRatio: Double
    /// The gap between parts placed above and below each other.
    var verticalSpacing: Double
    /// The gap between the column and the deck when side by side.
    var horizontalSpacing: Double

    /// The most of the height the summary may take when stacked. Offered less room than it
    /// needs, it condenses to one line, so the deck always keeps most of the height.
    static let maximumStackedSummaryShare = 0.25

    /// The arrangement with the larger card. Stacking wins ties, since the summary reads
    /// more easily across the full width.
    func frames(
        in bounds: CGRect,
        summarySize: (ProposedViewSize) -> CGSize,
        buttonsSize: (ProposedViewSize) -> CGSize
    ) -> Frames {
        let stacked = stackedFrames(in: bounds, summarySize: summarySize, buttonsSize: buttonsSize)
        guard let sideBySide = sideBySideFrames(in: bounds, summarySize: summarySize, buttonsSize: buttonsSize),
              cardHeight(in: sideBySide.deck.size) > cardHeight(in: stacked.deck.size)
        else { return stacked }
        return sideBySide
    }

    /// The summary at the top, the buttons at the bottom, and the deck filling the space between.
    func stackedFrames(
        in bounds: CGRect,
        summarySize: (ProposedViewSize) -> CGSize,
        buttonsSize: (ProposedViewSize) -> CGSize
    ) -> Frames {
        let buttonsHeight = min(buttonsSize(ProposedViewSize(width: bounds.width, height: nil)).height, bounds.height)
        let measuredSummaryHeight = summarySize(
            ProposedViewSize(width: bounds.width, height: bounds.height * Self.maximumStackedSummaryShare)
        ).height
        // Never taller than the space above the buttons, so the two can't overlap.
        let summaryHeight = min(measuredSummaryHeight, max(0, bounds.height - buttonsHeight - verticalSpacing))
        let deckHeight = max(0, bounds.height - summaryHeight - buttonsHeight - verticalSpacing * 2)

        return Frames(
            summary: CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: summaryHeight),
            deck: CGRect(
                x: bounds.minX,
                y: bounds.minY + summaryHeight + verticalSpacing,
                width: bounds.width,
                height: deckHeight
            ),
            buttons: CGRect(x: bounds.minX, y: bounds.maxY - buttonsHeight, width: bounds.width, height: buttonsHeight)
        )
    }

    /// The summary and buttons centered in the leading half, and the deck in the trailing
    /// half, or `nil` if the summary and buttons don't fit that half.
    func sideBySideFrames(
        in bounds: CGRect,
        summarySize: (ProposedViewSize) -> CGSize,
        buttonsSize: (ProposedViewSize) -> CGSize
    ) -> Frames? {
        let columnWidth = (bounds.width - horizontalSpacing) / 2
        let buttons = buttonsSize(ProposedViewSize(width: columnWidth, height: nil))
        let summary = summarySize(
            ProposedViewSize(width: columnWidth, height: max(0, bounds.height - buttons.height - verticalSpacing))
        )
        let columnHeight = summary.height + verticalSpacing + buttons.height

        // Either part reports more than it was offered when it can't shrink to fit.
        guard columnWidth > 0,
              columnHeight <= bounds.height,
              summary.width <= columnWidth,
              buttons.width <= columnWidth
        else { return nil }

        let columnTop = bounds.midY - columnHeight / 2
        return Frames(
            summary: CGRect(x: bounds.minX, y: columnTop, width: columnWidth, height: summary.height),
            deck: CGRect(x: bounds.maxX - columnWidth, y: bounds.minY, width: columnWidth, height: bounds.height),
            buttons: CGRect(
                x: bounds.minX,
                y: columnTop + summary.height + verticalSpacing,
                width: columnWidth,
                height: buttons.height
            )
        )
    }

    /// The height of the largest card that fits in a space, keeping the card's proportions.
    func cardHeight(in size: CGSize) -> Double {
        min(size.height, size.width / cardAspectRatio)
    }
}
