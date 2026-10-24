//
//  MainView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import CoreData
import CoreLocation
import SwiftUI

/// The swipe deck, its filters, and the app's top-level navigation.
struct MainView: View {
    #if DEBUG
    @State private var feed = ScreenshotMode.isEnabled ? ScreenshotMode.makeFeed() : RestaurantFeed()
    @State private var filters = ScreenshotMode.isEnabled ? ScreenshotMode.makeFilters() : FiltersState()
    #else
    @State private var feed = RestaurantFeed()
    @State private var filters = FiltersState()
    #endif
    @State private var storeManager = StoreManager()
    @State private var activeSheet: MainSheet?

    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.managedObjectContext) private var moc
    @AppStorage("userHasOpenedAppBefore") private var userHasOpenedAppBefore = false

    var body: some View {
        NavigationStack {
            FeedView(feed: feed, filters: filters, activeSheet: $activeSheet)
                .navigationTitle(feed.currentRestaurant?.location?.city ?? "Hot Local Food")
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    MainToolbar(activeSheet: $activeSheet)
                }
                .safeAreaInset(edge: .bottom) {
                    RemoveAdsBannerView()
                }
        }
        .tint(.fuchsia)
        .sheet(item: $activeSheet) { sheet in
            MainSheetContent(sheet: sheet, feed: feed, filters: filters)
        }
        .sensoryFeedback(.success, trigger: feed.successfulLoadCount)
        // Restarts when the first location arrives, ending the wait below.
        .task(id: locationViewModel.isAwaitingFirstLocation) { await loadInitialRestaurants() }
        .onAppear(perform: createFavoritesListOnFirstLaunch)
        .environment(storeManager)
    }

    /// Shows the previous session's results, or searches when there are none.
    /// Runs again when the first location arrives, to replace a fallback search.
    private func loadInitialRestaurants() async {
        guard feed.phase == .idle else {
            // The search stopped waiting for a location before this one arrived.
            if feed.isUsingFallbackLocation, locationViewModel.location != nil {
                await feed.refresh(filters: filters, currentLocation: locationViewModel.location)
            }
            return
        }
        #if DEBUG
        // Screenshots skip the caches and open the sheet their launch arguments name.
        if ScreenshotMode.isEnabled {
            await feed.refresh(filters: filters, currentLocation: nil)
            activeSheet = ScreenshotMode.sheet
            return
        }
        #endif
        Utils.clearYelpCachesOverAMonthOld()
        filters.restoreFromCache()
        guard !feed.restoreFromCache() else { return }

        // Right after permission is granted the first location is still on its
        // way. Searching now would search, and cache, the fallback coordinate.
        if locationViewModel.isAwaitingFirstLocation {
            try? await Task.sleep(for: .seconds(5))
            // A search the person started while waiting takes priority.
            guard !Task.isCancelled, feed.phase == .idle else { return }
        }
        await feed.refresh(filters: filters, currentLocation: locationViewModel.location)
    }

    private func createFavoritesListOnFirstLaunch() {
        guard !userHasOpenedAppBefore else { return }
        userHasOpenedAppBefore = true

        let request = SavedList.fetchRequest(named: "Favorites")
        guard ((try? moc.count(for: request)) ?? 0) == 0 else { return }

        let favoritesList = SavedList(context: moc)
        favoritesList.name = "Favorites"
        do {
            try moc.save()
        } catch {
            moc.rollback()
        }
    }
}

#Preview {
    MainView()
        .environment(LocationViewModel())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
