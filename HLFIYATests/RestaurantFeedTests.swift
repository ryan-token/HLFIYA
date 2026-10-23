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
        await feed.refresh(filters: FiltersState(), currentLocation: nil)
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
        await feed.refresh(filters: FiltersState(), currentLocation: nil)

        #expect(feed.phase == .failed)
        #expect(feed.restaurants.isEmpty)
        #expect(feed.successfulLoadCount == 0)
    }

    @Test func emptyResultsMeanNoResults() async {
        let feed = RestaurantFeed { _ in [] }
        await feed.refresh(filters: FiltersState(), currentLocation: nil)

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

    @Test func visibleCardsIncludeThePreviousCardAndTheTopCard() async {
        let feed = await loadedFeed()
        feed.swipeLeft()

        let cards = feed.visibleCards
        #expect(cards.map(\.position) == [0, 1, 2])
        #expect(cards.map(\.isSwipedAway) == [true, false, false])
        #expect(cards.map(\.isTopCard) == [false, true, false])
        #expect(cards.allSatisfy { !$0.showsSwipeHint })
    }

    @Test func searchPrefersTheCustomLocationThenTheCurrentLocation() {
        let filters = FiltersState(inMemory: true)
        let current = CLLocation(latitude: 40, longitude: -74)

        let aroundPerson = RestaurantFeed.searchRequest(filters: filters, currentLocation: current)
        #expect(aroundPerson.latitude == 40)
        #expect(aroundPerson.longitude == -74)

        let noLocation = RestaurantFeed.searchRequest(filters: filters, currentLocation: nil)
        #expect(noLocation.latitude == RestaurantFeed.fallbackCoordinate.latitude)

        filters.applyLocation(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), radius: 50)
        let custom = RestaurantFeed.searchRequest(filters: filters, currentLocation: current)
        #expect(custom.latitude == 51.5)
        // The radius is clamped to Yelp's 40 km maximum.
        #expect(custom.radiusInMeters == 40_000)
    }
}
