//
//  UndoSwipeAction.swift
//  HLFIYA
//

import SwiftUI

/// Brings back the most recently skipped card.
///
/// An action type rather than a closure, so views that receive it can still be
/// compared and skipped when nothing they display has changed.
struct UndoSwipeAction {
    let feed: RestaurantFeed

    private static let animation = Animation.interpolatingSpring(
        mass: 1,
        stiffness: 50,
        damping: 100,
        initialVelocity: 7
    )

    func callAsFunction() {
        withAnimation(Self.animation) {
            feed.undo()
        }
    }
}
