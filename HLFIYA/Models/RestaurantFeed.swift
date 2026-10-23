//
//  RestaurantFeed.swift
//  HLFIYA
//

import CoreLocation
import Foundation
import Observation
import os

/// The deck of restaurants on the main screen and the state of swiping through it.
///
/// Swiping left moves through `restaurants` by advancing `swipedCount`; every card
/// before that position has been swiped away. Undo moves it back by one.
@Observable
final class RestaurantFeed {
    enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case failed
    }

    /// The Apple Park coordinate used when no location is available.
    static let fallbackCoordinate = CLLocationCoordinate2D(latitude: 37.334633, longitude: -122.012682)

    /// How many upcoming cards are rendered beneath the current one.
    private static let upcomingCardCount = 2

    private(set) var restaurants: [Business] = []
    private(set) var swipedCount = 0
    private(set) var phase = Phase.idle
    /// Increments after each successful network load, to drive success feedback.
    private(set) var successfulLoadCount = 0

    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private let fetchBusinesses: @Sendable (BusinessSearch) async throws -> [Business]

    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "RestaurantFeed")

    init(fetchBusinesses: @escaping @Sendable (BusinessSearch) async throws -> [Business] = RestaurantFeed.liveFetch) {
        self.fetchBusinesses = fetchBusinesses
    }

    isolated deinit {
        loadTask?.cancel()
    }

    // MARK: Deck state

    var remainingCount: Int {
        restaurants.count - swipedCount
    }

    var canUndo: Bool {
        swipedCount > 0
    }

    var isExhausted: Bool {
        phase == .loaded && !restaurants.isEmpty && remainingCount == 0
    }

    var hasNoResults: Bool {
        phase == .loaded && restaurants.isEmpty
    }

    /// The card currently on top of the deck, if any remain.
    var currentRestaurant: Business? {
        restaurants.indices.contains(swipedCount) ? restaurants[swipedCount] : nil
    }

    /// The cards worth rendering: the last swiped card (so undo can animate it back)
    /// plus the current card and a few beneath it.
    var visibleCards: [DeckCard] {
        guard !restaurants.isEmpty else { return [] }
        let lowerBound = max(swipedCount - 1, 0)
        let upperBound = min(swipedCount + Self.upcomingCardCount, restaurants.count - 1)
        guard lowerBound <= upperBound else { return [] }

        return (lowerBound...upperBound).map { position in
            DeckCard(
                business: restaurants[position],
                position: position,
                isSwipedAway: position < swipedCount,
                isTopCard: position == swipedCount,
                showsSwipeHint: swipedCount == 0
            )
        }
    }

    func swipeLeft() {
        guard remainingCount > 0 else { return }
        swipedCount += 1
    }

    func undo() {
        guard canUndo else { return }
        swipedCount -= 1
    }

    // MARK: Loading

    /// Shows cached results from the previous session, returning whether any existed.
    func restoreFromCache() -> Bool {
        let cached = Utils.getLocalYelpCache()
        guard !cached.isEmpty else { return false }
        show(cached)
        return true
    }

    /// Starts a fresh search, cancelling any search already in flight.
    func reload(filters: FiltersState, currentLocation: CLLocation?) {
        let request = Self.searchRequest(filters: filters, currentLocation: currentLocation)
        loadTask?.cancel()
        loadTask = Task { await self.load(request) }
    }

    /// Runs a fresh search and waits for it to finish.
    func refresh(filters: FiltersState, currentLocation: CLLocation?) async {
        reload(filters: filters, currentLocation: currentLocation)
        await loadTask?.value
    }

    private func load(_ request: BusinessSearch) async {
        phase = .loading

        do {
            let fetched = try await fetchBusinesses(request)
            try Task.checkCancellation()
            show(fetched)
            successfulLoadCount += 1
        } catch is CancellationError {
            // A newer search replaced this one; it owns the phase now.
        } catch {
            guard !Task.isCancelled else { return }
            Self.logger.error("Failed to load restaurants: \(error.localizedDescription, privacy: .public)")
            phase = .failed
        }
    }

    private func show(_ businesses: [Business]) {
        restaurants = businesses
        swipedCount = 0
        phase = .loaded
    }

    /// Builds a search from the filters, preferring a custom location, then the
    /// person's location, then the fallback coordinate.
    static func searchRequest(filters: FiltersState, currentLocation: CLLocation?) -> BusinessSearch {
        BusinessSearch(
            coordinate: filters.customCoordinate ?? currentLocation?.coordinate ?? fallbackCoordinate,
            radiusInMeters: Utils.convertMilesToMeters(miles: filters.radius),
            categories: filters.categories.categories,
            prices: filters.prices.apiValue,
            openNow: filters.openNow
        )
    }

    nonisolated static func liveFetch(_ search: BusinessSearch) async throws -> [Business] {
        try await BusinessFetcher.getBusinesses(for: search)
    }
}
