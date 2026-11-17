//
//  CardInfoOverlay.swift
//  HLFIYA
//

import SwiftUI

/// The status badge and footer laid over a card's photo, at the largest size that fits.
///
/// Small cards, such as on iPhone Duo's outer display with a banner ad, drop the badge and
/// then step down through smaller footers, so nothing overlaps or runs past the card's edges.
struct CardInfoOverlay: View {
    let showsSwipeHint: Bool
    let photosFailedToLoad: Bool
    let summary: CardSummary
    let canUndo: Bool
    let undo: UndoSwipeAction

    var body: some View {
        ViewThatFits {
            CardInfoContent(
                showsSwipeHint: showsSwipeHint,
                photosFailedToLoad: photosFailedToLoad,
                summary: summary,
                canUndo: canUndo,
                undo: undo,
                style: .regular
            )
            ForEach(CardFooterStyle.allCases, id: \.self) { style in
                CardInfoContent(
                    showsSwipeHint: false,
                    // A failed photo load stays visible for as long as anything fits.
                    photosFailedToLoad: style != .minimal && photosFailedToLoad,
                    summary: summary,
                    canUndo: canUndo,
                    undo: undo,
                    style: style
                )
            }
        }
        // The card can't grow, so accessibility sizes would leave no room for the photo.
        // The details sheet and the card's VoiceOver label carry everything at any size.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
