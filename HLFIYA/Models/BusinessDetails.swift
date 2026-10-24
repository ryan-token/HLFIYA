//
//  BusinessDetails.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/8/22.
//

import Foundation

/// The full details for one restaurant, from the Yelp business details endpoint.
nonisolated struct BusinessDetails: Identifiable, Codable, Equatable {
    // The same fields as `Business`.
    var id: String?
    var rating: Double?
    var price: String?
    var phone: String?
    var displayPhone: String?
    var alias: String?
    var isClosed: Bool?
    var categories: [Category]?
    var reviewCount: Int?
    var name: String?
    var url: String?
    var coordinates: Coordinates?
    var imageURL: String?
    var location: Location?
    var distance: Double?
    var transactions: [String]?

    // Only in the details endpoint.
    var isClaimed: Bool?
    var photos: [String]?
    var hours: [Hours]?
    var specialHours: [SpecialHours]?

    // Decoded with `JSONDecoder.yelp`, which converts snake_case keys to camelCase,
    // so only the acronym needs an explicit key.
    enum CodingKeys: String, CodingKey {
        case id, rating, price, phone, displayPhone, alias, isClosed, categories, reviewCount
        case name, url, coordinates, location, distance, transactions
        case isClaimed, photos, hours, specialHours
        case imageURL = "imageUrl"
    }
}

extension BusinessDetails {
    /// The photo URLs without blanks or repeats, in Yelp's order.
    nonisolated var photoURLs: [String] {
        var seen = Set<String>()
        return (photos ?? []).filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    nonisolated struct Category: Codable, Hashable {
        var alias: String?
        var title: String?
    }

    nonisolated struct Coordinates: Codable, Equatable {
        var latitude: Double?
        var longitude: Double?
    }

    nonisolated struct Location: Codable, Equatable {
        var city: String?
        var country: String?
        var address2: String?
        var address3: String?
        var state: String?
        var address1: String?
        var zipCode: String?
        var displayAddress: [String]?
    }

    nonisolated struct Hours: Codable, Hashable {
        var open: [Hour]?
        var hoursType: String?
        var isOpenNow: Bool?
    }

    nonisolated struct Hour: Codable, Hashable {
        var isOvernight: Bool?
        var start: String?
        var end: String?
        var day: Int?
    }

    nonisolated struct SpecialHours: Codable, Equatable {
        var date: String?
        var isClosed: Bool?
        var start: String?
        var end: String?
        var isOvernight: Bool?
    }
}

// MARK: Sample data

nonisolated extension BusinessDetails {
    /// A sample restaurant for previews and tests.
    static let data = BusinessDetails(
        id: "E8RJkjfdcwgtyoPMjQ_Olg",
        rating: 4.0,
        price: "$",
        phone: "+14152520800",
        displayPhone: "",
        alias: "four-barrel-coffee-san-francisco",
        isClosed: false,
        categories: [Category(alias: "coffee", title: "Coffee & Tea")],
        reviewCount: 1738,
        name: "Four Barrel Coffee",
        url: "https://www.yelp.com/biz/four-barrel-coffee-san-francisco",
        coordinates: Coordinates(latitude: 37.7670169511878, longitude: -122.42184275),
        imageURL: "https://s3-media2.fl.yelpcdn.com/bphoto/MmgtASP3l_t4tPCL1iAsCg/o.jpg",
        location: Location(
            city: "San Francisco",
            country: "US",
            address2: "",
            address3: "",
            state: "CA",
            address1: "375 Valencia St",
            zipCode: "94103",
            displayAddress: ["375 Valencia St", "San Francisco, CA 94103"]
        ),
        distance: 1604.23,
        transactions: ["pickup", "delivery"],
        isClaimed: false,
        photos: [
            "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg",
            "https://s3-media4.fl.yelpcdn.com/bphoto/ahmWdH7P0UIc4lM1c8zhcQ/o.jpg",
            "https://s3-media2.fl.yelpcdn.com/bphoto/BlG7QLi2mseijvxFnAb5yg/o.jpg"
        ],
        hours: [
            Hours(
                open: (0...6).map { Hour(isOvernight: false, start: "1100", end: "2000", day: $0) },
                hoursType: "Regular",
                isOpenNow: true
            )
        ],
        specialHours: [
            SpecialHours(date: "2022-11-24", isClosed: true, start: nil, end: nil, isOvernight: nil),
            SpecialHours(date: "2022-12-24", isClosed: nil, start: "1100", end: "1500", isOvernight: false)
        ]
    )
}
