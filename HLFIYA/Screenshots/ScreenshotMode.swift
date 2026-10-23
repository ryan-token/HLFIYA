//
//  ScreenshotMode.swift
//  HLFIYA
//

#if DEBUG
import CoreData
import CoreLocation
import os

/// Made-up restaurants and lists for App Store screenshots, turned on with the
/// `-ScreenshotMode` launch argument.
///
/// Searches return `ScreenshotRestaurant.all` instead of calling Yelp, filters and
/// lists stay in memory, Core Data never syncs with iCloud, and ads, purchases,
/// review requests and the location prompt are skipped. Photos still load from
/// Unsplash's CDN by fixed ID.
///
/// Other launch arguments open each screen without touches, for displays that
/// can't be driven by AXe, such as iPhone Duo's inner display:
/// - `-ScreenshotTop "<name>"` moves that restaurant to the top of the deck.
/// - `-ScreenshotDrag <points>` holds the top card mid-swipe; negative is left.
/// - `-ScreenshotDetails` opens the top card's details.
/// - `-ScreenshotSheet lists|categories|prices|location|settings` opens that sheet.
nonisolated enum ScreenshotMode {
    static let isEnabled = ProcessInfo.processInfo.arguments.contains("-ScreenshotMode")

    /// The Mission District, the search area every screenshot shows.
    static let searchCenter = CLLocationCoordinate2D(latitude: 37.7599, longitude: -122.4148)

    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "ScreenshotMode")

    /// The value after a launch argument such as `-ScreenshotTop "Tide & Roll"`.
    static func argument(_ flag: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else { return nil }
        return arguments[index + 1]
    }

    // MARK: Restaurants

    /// The deck, with the restaurant named by `-ScreenshotTop` moved to the top.
    static let restaurants: [Business] = {
        var restaurants = ScreenshotRestaurant.all
        if let name = argument("-ScreenshotTop") {
            if let index = restaurants.firstIndex(where: { $0.name == name }) {
                restaurants.insert(restaurants.remove(at: index), at: 0)
            } else {
                logger.error("No screenshot restaurant named \(name, privacy: .public)")
            }
        }
        return restaurants.map(\.business)
    }()

    static func details(id: String) throws -> BusinessDetails {
        guard let restaurant = ScreenshotRestaurant.all.first(where: { $0.id == id }) else {
            throw URLError(.fileDoesNotExist)
        }
        return restaurant.details
    }

    /// How far the top card is held mid-swipe, from `-ScreenshotDrag`.
    static let dragDistance = argument("-ScreenshotDrag").flatMap(Double.init) ?? 0

    static let opensDetails = ProcessInfo.processInfo.arguments.contains("-ScreenshotDetails")

    // MARK: App state

    @MainActor
    static func makeFeed() -> RestaurantFeed {
        RestaurantFeed { _ in restaurants }
    }

    /// Filters that match every sample restaurant, kept in memory so the person's own filters are untouched.
    @MainActor
    static func makeFilters() -> FiltersState {
        let filters = FiltersState(inMemory: true)
        let categories: Set<String> = [
            "breakfast_brunch", "burgers", "desserts", "indpak", "italian",
            "japanese", "mexican", "pizza", "steak", "sushi", "vegetarian"
        ]
        filters.applyCategories(CategorySelection(categories: categories), openNow: true)
        filters.applyLocation(center: searchCenter, radius: 2)
        return filters
    }

    /// The sheet named by `-ScreenshotSheet`.
    @MainActor
    static var sheet: MainSheet? {
        guard let name = argument("-ScreenshotSheet") else { return nil }
        switch name {
        case "lists": return .lists
        case "categories": return .categories
        case "prices": return .prices
        case "location": return .location
        case "settings": return .settings
        default:
            logger.error("No screenshot sheet named \(name, privacy: .public)")
            return nil
        }
    }

    /// An in-memory store, which `PersistenceController` keeps out of iCloud in screenshot mode.
    @MainActor
    static func makePersistenceController() -> PersistenceController {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        let restaurants = Dictionary(uniqueKeysWithValues: ScreenshotRestaurant.all.map { ($0.name, $0) })

        let lists: [(name: String, restaurants: [String])] = [
            ("Favorites", ["Ember & Crust", "Golden Hour Ramen", "Little Lime", "Tide & Roll"]),
            ("Date Night", ["Copper & Oak", "Nonna's Table", "Tide & Roll"]),
            ("Brunch Spots", ["Sunny Side Café"]),
            ("Late-Night Eats", ["Little Lime", "Smash Club"]),
            ("Try Soon", ["Saffron Street", "Greenleaf Bowls"]),
            ("Sweet Treats", ["Sprinkle Lab"]),
            ("Patio Weather", ["Ember & Crust"]),
            ("Takeout Night", ["Saffron Street", "Golden Hour Ramen"])
        ]

        var savedRestaurants: [String: SavedRestaurant] = [:]
        for list in lists {
            let savedList = SavedList(context: context)
            savedList.name = list.name
            for name in list.restaurants {
                guard let restaurant = restaurants[name] else { continue }
                let saved = savedRestaurants[name] ?? SavedRestaurant(context: context)
                saved.id = restaurant.id
                saved.name = name
                saved.addToLists(savedList)
                savedRestaurants[name] = saved
            }
        }

        do {
            try context.save()
        } catch {
            logger.error("Failed to seed the screenshot store: \(error.localizedDescription, privacy: .public)")
        }
        return controller
    }
}
#endif
