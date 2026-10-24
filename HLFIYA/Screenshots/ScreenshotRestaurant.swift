//
//  ScreenshotRestaurant.swift
//  HLFIYA
//

#if DEBUG
import Foundation

/// A made-up restaurant for App Store screenshots, with free-licensed Unsplash food photos.
///
/// Names, phone numbers (555) and street numbers are invented, so no real business appears.
nonisolated struct ScreenshotRestaurant {
    let name: String
    let categories: [(alias: String, title: String)]
    let price: String
    let rating: Double
    let reviewCount: Int
    let address: String
    let phoneSuffix: String
    /// Unsplash photo IDs; the first is the card's cover.
    let photoIDs: [String]

    var id: String {
        "screenshot-" + name.lowercased().filter { $0.isLetter || $0 == " " }.replacing(" ", with: "-")
    }

    var business: Business {
        Business(
            id: id,
            rating: rating,
            price: price,
            phone: "+1415555\(phoneSuffix)",
            displayPhone: "(415) 555-\(phoneSuffix)",
            alias: id,
            isClosed: false,
            categories: categories.map { Business.Category(alias: $0.alias, title: $0.title) },
            reviewCount: reviewCount,
            name: name,
            url: "https://www.yelp.com",
            coordinates: Business.Coordinates(
                latitude: ScreenshotMode.searchCenter.latitude,
                longitude: ScreenshotMode.searchCenter.longitude
            ),
            imageURL: photoURLs.first,
            location: Business.Location(
                city: "San Francisco",
                country: "US",
                address2: nil,
                address3: nil,
                state: "CA",
                address1: address,
                zipCode: "94110",
                displayAddress: [address, "San Francisco, CA 94110"]
            ),
            distance: 800,
            transactions: ["pickup", "delivery"]
        )
    }

    var details: BusinessDetails {
        BusinessDetails(
            id: id,
            rating: rating,
            price: price,
            phone: "+1415555\(phoneSuffix)",
            displayPhone: "(415) 555-\(phoneSuffix)",
            alias: id,
            isClosed: false,
            categories: categories.map { BusinessDetails.Category(alias: $0.alias, title: $0.title) },
            reviewCount: reviewCount,
            name: name,
            url: "https://www.yelp.com",
            coordinates: BusinessDetails.Coordinates(
                latitude: ScreenshotMode.searchCenter.latitude,
                longitude: ScreenshotMode.searchCenter.longitude
            ),
            imageURL: photoURLs.first,
            location: BusinessDetails.Location(
                city: "San Francisco",
                country: "US",
                state: "CA",
                address1: address,
                zipCode: "94110",
                displayAddress: [address, "San Francisco, CA 94110"]
            ),
            distance: 800,
            transactions: ["pickup", "delivery"],
            isClaimed: true,
            photos: photoURLs,
            hours: [
                BusinessDetails.Hours(
                    open: (0...6).map { BusinessDetails.Hour(isOvernight: false, start: "1100", end: "2200", day: $0) },
                    hoursType: "REGULAR",
                    isOpenNow: true
                )
            ]
        )
    }

    private var photoURLs: [String] {
        photoIDs.map { "https://images.unsplash.com/photo-\($0)?w=1600&q=80&fm=jpg" }
    }
}

nonisolated extension ScreenshotRestaurant {
    /// The deck, in order. Every category is one the screenshot filters select.
    static let all: [ScreenshotRestaurant] = [
        ScreenshotRestaurant(
            name: "Ember & Crust",
            categories: [("pizza", "Pizza"), ("italian", "Italian")],
            price: "$$", rating: 4.5, reviewCount: 1284, address: "2140 Valencia St", phoneSuffix: "0142",
            photoIDs: ["1565299624946-b28f40a0ae38", "1513104890138-7c749659a591", "1517248135467-4c7edcad34c4"]
        ),
        ScreenshotRestaurant(
            name: "Golden Hour Ramen",
            categories: [("japanese", "Japanese"), ("ramen", "Ramen")],
            price: "$$", rating: 4.5, reviewCount: 932, address: "3318 18th St", phoneSuffix: "0187",
            photoIDs: ["1557872943-16a5ac26437e", "1569718212165-3a8278d5f624", "1555396273-367ea4eb4db5"]
        ),
        ScreenshotRestaurant(
            name: "Little Lime",
            categories: [("mexican", "Mexican"), ("tacos", "Tacos")],
            price: "$", rating: 4.5, reviewCount: 2210, address: "2975 Mission St", phoneSuffix: "0119",
            photoIDs: ["1565299585323-38d6b0865b47", "1551504734-5ee1c4a1479b"]
        ),
        ScreenshotRestaurant(
            name: "Smash Club",
            categories: [("burgers", "Burgers")],
            price: "$$", rating: 4.0, reviewCount: 756, address: "1876 Harrison St", phoneSuffix: "0163",
            photoIDs: ["1568901346375-23c9450c58cd"]
        ),
        ScreenshotRestaurant(
            name: "Saffron Street",
            categories: [("indpak", "Indian")],
            price: "$$", rating: 4.5, reviewCount: 1103, address: "3460 24th St", phoneSuffix: "0128",
            photoIDs: ["1585937421612-70a008356fbe", "1565557623262-b51c2513a641", "1559847844-5315695dadae"]
        ),
        ScreenshotRestaurant(
            name: "Tide & Roll",
            categories: [("sushi", "Sushi Bars"), ("japanese", "Japanese")],
            price: "$$$", rating: 4.5, reviewCount: 648, address: "2590 Folsom St", phoneSuffix: "0174",
            photoIDs: ["1579871494447-9811cf80d66c", "1553621042-f6e147245754"]
        ),
        ScreenshotRestaurant(
            name: "Sunny Side Café",
            categories: [("breakfast_brunch", "Breakfast & Brunch")],
            price: "$$", rating: 4.0, reviewCount: 1890, address: "1215 Guerrero St", phoneSuffix: "0135",
            photoIDs: ["1484723091739-30a097e8f929", "1533089860892-a7c6f0a88666"]
        ),
        ScreenshotRestaurant(
            name: "Nonna's Table",
            categories: [("italian", "Italian")],
            price: "$$", rating: 4.5, reviewCount: 1342, address: "3082 22nd St", phoneSuffix: "0156",
            photoIDs: ["1621996346565-e3dbc646d9a9", "1563379926898-05f4575a45d8", "1467003909585-2f8a72700288"]
        ),
        ScreenshotRestaurant(
            name: "Greenleaf Bowls",
            categories: [("vegetarian", "Vegetarian")],
            price: "$", rating: 4.0, reviewCount: 412, address: "2755 Bryant St", phoneSuffix: "0191",
            photoIDs: ["1546069901-ba9599a7e63c", "1512621776951-a57141f2eefd", "1540189549336-e6e99c3679fe"]
        ),
        ScreenshotRestaurant(
            name: "Copper & Oak",
            categories: [("steak", "Steakhouses")],
            price: "$$$$", rating: 4.5, reviewCount: 987, address: "1630 Dolores St", phoneSuffix: "0108",
            photoIDs: ["1600891964092-4316c288032e", "1544025162-d76694265947", "1559339352-11d035aa65de"]
        ),
        ScreenshotRestaurant(
            name: "Sprinkle Lab",
            categories: [("desserts", "Desserts"), ("donuts", "Donuts")],
            price: "$", rating: 5.0, reviewCount: 377, address: "3195 16th St", phoneSuffix: "0122",
            photoIDs: ["1551024601-bec78aea704b", "1563805042-7684c019e1cb"]
        )
    ]
}
#endif
