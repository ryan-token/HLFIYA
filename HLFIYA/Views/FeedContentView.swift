//
//  FeedContentView.swift
//  HLFIYA
//

import SwiftUI

/// The swipe deck, or the loading, empty, or error state that replaces it.
struct FeedContentView: View {
    let feed: RestaurantFeed
    let filters: FiltersState

    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if feed.hasNoResults {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try changing your filters.")
                )
                .transition(Self.fade)
            } else if feed.phase == .failed {
                // Also replaces a stale deck, which no longer matches the filters
                // or has run out, so there's always a way to try again.
                ContentUnavailableView {
                    Label("Couldn't Load Restaurants", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Check your connection and try again.")
                } actions: {
                    AsyncButton("Try Again", systemImage: "arrow.clockwise", action: refresh)
                        .buttonStyle(.glassProminent)
                }
                .transition(Self.fade)
            } else if feed.restaurants.isEmpty {
                ProgressView()
                    .transition(Self.fade)
            } else {
                CardDeckView(feed: feed)
                    .transition(deckTransition)
                    .animation(.snappy) { deck in
                        deck.opacity(feed.phase == .loading ? 0.4 : 1)
                    }
                    // Swipes on the old deck would be lost when the new results arrive.
                    .allowsHitTesting(feed.phase != .loading)
                    .overlay {
                        if feed.phase == .loading {
                            ProgressView()
                                .transition(Self.fade)
                        }
                    }

                if feed.isExhausted {
                    AsyncButton("Refresh Food", systemImage: "arrow.clockwise.circle", action: refresh)
                        .font(.headline)
                        .buttonStyle(.glassProminent)
                        .transition(Self.fade)
                }
            }
        }
    }

    // Each state animates only its own appearance. An animation on the whole
    // container would also animate the layout settling at launch, sliding the
    // deck in from the corner.
    private static let fade = AnyTransition.opacity.animation(.snappy)

    /// The first results grow out from the center of the space they fill.
    private var deckTransition: AnyTransition {
        reduceMotion ? Self.fade : .scale(scale: 0.85).combined(with: .opacity).animation(.snappy)
    }

    private func refresh() async {
        await feed.refresh(filters: filters, currentLocation: locationViewModel.location)
    }
}

#Preview {
    FeedContentView(feed: RestaurantFeed(), filters: FiltersState())
        .environment(LocationViewModel())
}
