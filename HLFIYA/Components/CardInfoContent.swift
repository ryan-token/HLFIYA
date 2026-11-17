//
//  CardInfoContent.swift
//  HLFIYA
//

import SwiftUI

/// One arrangement of a card's overlay: the status badge at the top and the footer at the
/// bottom, kept apart so they never overlap.
struct CardInfoContent: View {
    let showsSwipeHint: Bool
    let photosFailedToLoad: Bool
    let summary: CardSummary
    let canUndo: Bool
    let undo: UndoSwipeAction
    let style: CardFooterStyle

    var body: some View {
        VStack(spacing: 0) {
            // Takes no room when there's nothing to show, so the footer gets it instead.
            if showsSwipeHint || photosFailedToLoad {
                CardStatusBadge(showsSwipeHint: showsSwipeHint, photosFailedToLoad: photosFailedToLoad)
            }

            Spacer(minLength: 0)

            CardFooter(summary: summary, canUndo: canUndo, undo: undo, style: style)
        }
    }
}
