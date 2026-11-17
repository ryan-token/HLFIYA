//
//  FeedView.swift
//  HLFIYA
//

import SwiftUI

/// The filter summary, the swipe deck, and the filter buttons, arranged for the
/// available space.
///
/// `FeedLayout` stacks them or places them side by side, whichever gives the cards more
/// room, so the deck stays as large as possible on any window, including iPhone Duo's
/// short outer display with a banner ad below.
struct FeedView: View {
    let feed: RestaurantFeed
    let filters: FiltersState
    @Binding var activeSheet: MainSheet?

    var body: some View {
        FeedLayout(cardAspectRatio: CardDeckView.aspectRatio) {
            FilterSummaryView(filters: filters)
            FeedContentView(feed: feed, filters: filters)
            FilterBar(activeSheet: $activeSheet)
        }
        // Outside the layout, so the frames it compares are the space the cards really get.
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var feed = RestaurantFeed { _ in Business.data }

    NavigationStack {
        FeedView(feed: feed, filters: FiltersState(), activeSheet: .constant(nil))
            .navigationTitle("San Francisco")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                MainToolbar(activeSheet: .constant(nil))
            }
    }
    .environment(LocationViewModel())
    .task {
        await feed.refresh(filters: FiltersState(), currentLocation: nil)
    }
}

/// iPhone Duo's outer display, with room for the "Remove Ads" button and a banner ad.
#Preview("Short Window with Ad", traits: .fixedLayout(width: 466, height: 678)) {
    @Previewable @State var feed = RestaurantFeed { _ in Business.data }

    NavigationStack {
        FeedView(feed: feed, filters: FiltersState(), activeSheet: .constant(nil))
            .navigationTitle("Littleton")
            .toolbarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Color.gray
                    .frame(height: 90)
                    .overlay { Text(verbatim: "Ad") }
            }
    }
    .environment(LocationViewModel())
    .task {
        await feed.refresh(filters: FiltersState(), currentLocation: nil)
    }
}
