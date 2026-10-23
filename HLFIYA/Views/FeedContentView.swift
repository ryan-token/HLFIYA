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

    var body: some View {
        ZStack {
            if feed.hasNoResults {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try changing your filters.")
                )
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
            } else if feed.restaurants.isEmpty {
                ProgressView()
            } else {
                CardDeckView(feed: feed)
                    .opacity(feed.phase == .loading ? 0.4 : 1)
                    .overlay {
                        if feed.phase == .loading {
                            ProgressView()
                        }
                    }

                if feed.isExhausted {
                    AsyncButton("Refresh Food", systemImage: "arrow.clockwise.circle", action: refresh)
                        .font(.headline)
                        .buttonStyle(.glassProminent)
                }
            }
        }
        .animation(.default, value: feed.phase)
    }

    private func refresh() async {
        await feed.refresh(filters: filters, currentLocation: locationViewModel.location)
    }
}

#Preview {
    FeedContentView(feed: RestaurantFeed(), filters: FiltersState())
        .environment(LocationViewModel())
}
