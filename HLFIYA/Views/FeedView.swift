//
//  FeedView.swift
//  HLFIYA
//

import SwiftUI

/// The filter summary and the swipe deck, arranged for the available space.
///
/// Landscape windows place the summary beside the deck; portrait ones, including
/// iPhone Duo's unfolded inner display, stack it above so the deck can use the
/// full width. This follows the window's shape rather than its size class, since
/// the inner display is regular width in portrait too. An `AnyLayout` switches
/// the arrangement without resetting the deck's state, so folding or rotating
/// mid-swipe keeps the current card.
struct FeedView: View {
    let feed: RestaurantFeed
    let filters: FiltersState

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var isLandscape = false

    var body: some View {
        let layout = usesSideBySideLayout
            ? AnyLayout(HStackLayout())
            : AnyLayout(VStackLayout())

        layout {
            FilterSummaryView(filters: filters)
                .frame(maxWidth: usesSideBySideLayout ? .infinity : nil)

            FeedContentView(feed: feed, filters: filters)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal)
        .onGeometryChange(for: Bool.self) { proxy in
            proxy.size.width > proxy.size.height
        } action: { isLandscape in
            self.isLandscape = isLandscape
        }
    }

    /// The size class answers before the first layout pass on a landscape iPhone,
    /// so the deck doesn't start stacked and then jump.
    private var usesSideBySideLayout: Bool {
        isLandscape || verticalSizeClass == .compact
    }
}

#Preview {
    @Previewable @State var feed = RestaurantFeed { _ in Business.data }

    NavigationStack {
        FeedView(feed: feed, filters: FiltersState())
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
