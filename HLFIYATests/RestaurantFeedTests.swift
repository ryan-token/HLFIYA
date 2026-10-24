//
//  RestaurantFeedTests.swift
//  HLFIYATests
//

import CoreLocation
@testable import HLFIYA
import Testing

@MainActor
struct RestaurantFeedTests {
    private struct FetchFailure: Error {}

    /// A feed whose searches return the sample restaurants.
    private func loadedFeed() async -> RestaurantFeed {
        let feed = RestaurantFeed { _ in Business.data }
        await feed.refresh(filters: FiltersState(inMemory: true), currentLocation: nil)
        return feed
    }

    @Test func refreshLoadsRestaurantsAndCountsSuccess() async {
        let feed = await loadedFeed()

        #expect(feed.phase == .loaded)
        #expect(feed.restaurants == Business.data)
        #expect(feed.swipedCount == 0)
        #expect(feed.successfulLoadCount == 1)
        #expect(feed.currentRestaurant == Business.data[0])
    }

    @Test func failedRefreshReportsFailure() async {
        let feed = RestaurantFeed { _ in throw FetchFailure() }
        await feed.refresh(filters: FiltersState(inMemory: true), currentLocation: nil)

        #expect(feed.phase == .failed)
        #expect(feed.restaurants.isEmpty)
        #expect(feed.successfulLoadCount == 0)
    }

    @Test func emptyResultsMeanNoResults() async {
        let feed = RestaurantFeed { _ in [] }
        await feed.refresh(filters: FiltersState(inMemory: true), currentLocation: nil)

        #expect(feed.hasNoResults)
        #expect(!feed.isExhausted)
    }

    @Test func swipingThroughEveryCardExhaustsTheDeck() async {
        let feed = await loadedFeed()

        for _ in Business.data {
            feed.swipeLeft()
        }
        // Extra swipes past the end are ignored.
        feed.swipeLeft()

        #expect(feed.swipedCount == Business.data.count)
        #expect(feed.remainingCount == 0)
        #expect(feed.isExhausted)
        #expect(feed.currentRestaurant == nil)
    }

    @Test func undoBringsBackThePreviousCard() async {
        let feed = await loadedFeed()
        #expect(!feed.canUndo)

        feed.swipeLeft()
        #expect(feed.canUndo)
        feed.undo()

        #expect(feed.swipedCount == 0)
        #expect(feed.currentRestaurant == Business.data[0])
        // Undo with nothing swiped is ignored.
        feed.undo()
        #expect(feed.swipedCount == 0)
    }

    @Test func visibleCardsAreTheTopCardAndTwoBeneathIt() async {
        let restaurants = (0..<6).map { Business.fixture(id: "\($0)") }
        let feed = RestaurantFeed { _ in restaurants }
        await feed.refresh(filters: FiltersState(inMemory: true), currentLocation: nil)

        let firstCards = feed.visibleCards
        #expect(firstCards.map(\.position) == [0, 1, 2])
        #expect(firstCards.allSatisfy { $0.showsSwipeHint })

        feed.swipeLeft()
        feed.swipeLeft()

        // The last swiped card stays so undo can animate it back.
        let cards = feed.visibleCards
        #expect(cards.map(\.position) == [1, 2, 3, 4])
        #expect(cards.map(\.isSwipedAway) == [true, false, false, false])
        #expect(cards.map(\.isTopCard) == [false, true, false, false])
        #expect(cards.allSatisfy { !$0.showsSwipeHint })
    }

    @Test func newerSearchWinsOverOneStillInFlight() async {
        let (gate, openGate) = AsyncStream.makeStream(of: Void.self)
        let (started, signalStarted) = AsyncStream.makeStream(of: Void.self)
        let feed = RestaurantFeed { search in
            guard search.openNow else { return Business.data }
            signalStarted.yield()
            // An unstructured task ignores cancellation, so the stale search
            // finishes after the newer one, as a slow request would.
            await Task { for await _ in gate {} }.value
            return [Business.data[0]]
        }

        let staleFilters = FiltersState(inMemory: true)
        staleFilters.applyCategories(CategorySelection(), openNow: true)
        let staleSearch = Task { await feed.refresh(filters: staleFilters, currentLocation: nil) }
        for await _ in started { break }

        await feed.refresh(filters: FiltersState(inMemory: true), currentLocation: nil)
        openGate.finish()
        await staleSearch.value

        #expect(feed.restaurants == Business.data)
        #expect(feed.phase == .loaded)
        #expect(feed.successfulLoadCount == 1)
    }

    @Test func searchPrefersTheCustomLocationThenTheCurrentLocation() {
        let filters = FiltersState(inMemory: true)
        let current = CLLocation(latitude: 40, longitude: -74)

        let aroundPerson = RestaurantFeed.searchRequest(filters: filters, currentLocation: current)
        #expect(aroundPerson.latitude == 40)
        #expect(aroundPerson.longitude == -74)
        #expect(!aroundPerson.usesFallbackLocation)

        let noLocation = RestaurantFeed.searchRequest(filters: filters, currentLocation: nil)
        #expect(noLocation.latitude == RestaurantFeed.fallbackCoordinate.latitude)
        #expect(noLocation.usesFallbackLocation)

        filters.applyLocation(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), radius: 50)
        let custom = RestaurantFeed.searchRequest(filters: filters, currentLocation: current)
        #expect(custom.latitude == 51.5)
        // The radius is clamped to Yelp's 40 km maximum.
        #expect(custom.radiusInMeters == 40_000)
    }
}
