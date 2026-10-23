//
//  Businesses.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import Foundation

/// A Yelp business search response.
nonisolated struct Businesses: Codable, Equatable {
    let total: Int?
    let businesses: [Business]?
    let region: Region?
}

/// A restaurant returned by the Yelp business search endpoint.
///
/// Swipe and drag state deliberately lives in the views and in `RestaurantFeed`, not here,
/// so that a drag on one card never mutates the array every other card reads.
nonisolated struct Business: Identifiable, Codable, Equatable {
    let id: String?
    let rating: Double?
    let price: String?
    let phone: String?
    let displayPhone: String?
    let alias: String?
    let isClosed: Bool?
    let categories: [Category]?
    let reviewCount: Int?
    let name: String?
    let url: String?
    let coordinates: Coordinates?
    let imageURL: String?
    let location: Location?
    let distance: Double?
    let transactions: [String]?

    // Decoded with `JSONDecoder.yelp`, which converts snake_case keys to camelCase,
    // so only the acronym needs an explicit key.
    enum CodingKeys: String, CodingKey {
        case id, rating, price, phone, displayPhone, alias, isClosed, categories, reviewCount
        case name, url, coordinates, location, distance, transactions
        case imageURL = "imageUrl"
    }
}

extension Business {
    nonisolated struct Category: Codable, Equatable {
        let alias: String
        let title: String
    }

    nonisolated struct Coordinates: Codable, Equatable {
        let latitude: Double
        let longitude: Double
    }

    nonisolated struct Location: Codable, Equatable {
        let city: String
        let country: String
        let address2: String?
        let address3: String?
        let state: String
        let address1: String?
        let zipCode: String
        let displayAddress: [String]?
    }
}

extension Businesses {
    nonisolated struct Region: Codable, Equatable {
        let center: Center
    }

    nonisolated struct Center: Codable, Equatable {
        let longitude: Double
        let latitude: Double
    }
}

// MARK: Sample data

nonisolated extension Business {
    /// Sample restaurants for previews and tests.
    static let data: [Business] = [
        Business(
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
                displayAddress: [""]
            ),
            distance: 1604.23,
            transactions: ["pickup", "delivery"]
        ),
        Business(
            id: "Xg-FyjVKAN70LO4u4Z1ozg",
            rating: 4.5,
            price: "$$",
            phone: "+14153917117",
            displayPhone: "(415) 391-7117",
            alias: "hog-island-oyster-san-francisco-2",
            isClosed: false,
            categories: [
                Category(alias: "seafood", title: "Seafood"),
                Category(alias: "seafoodmarkets", title: "Seafood Markets"),
                Category(alias: "raw_food", title: "Live/Raw Food")
            ],
            reviewCount: 6352,
            name: "Hog Island Oyster",
            url: "https://www.yelp.com/biz/hog-island-oyster-san-francisco-2",
            coordinates: Coordinates(latitude: 37.795831, longitude: -122.393303),
            imageURL: "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg",
            location: Location(
                city: "San Francisco",
                country: "US",
                address2: "",
                address3: "Shop 11",
                state: "CA",
                address1: "1 Ferry Bldg",
                zipCode: "94111",
                displayAddress: ["1 Ferry Bldg", "Shop 11", "San Francisco, CA 94111"]
            ),
            distance: 1154.8167382059307,
            transactions: ["pickup"]
        ),
        Business(
            id: "bUr4iq2mKKiBOu2HKynylg",
            rating: 4.0,
            price: "$$",
            phone: "+14155432355",
            displayPhone: "(415) 543-2355",
            alias: "hrd-san-francisco-4",
            isClosed: false,
            categories: [
                Category(alias: "korean", title: "Korean"),
                Category(alias: "asianfusion", title: "Asian Fusion"),
                Category(alias: "mexican", title: "Mexican")
            ],
            reviewCount: 2518,
            name: "HRD",
            url: "https://www.yelp.com/biz/hrd-san-francisco-4",
            coordinates: Coordinates(latitude: 37.7811065758548, longitude: -122.395329724426),
            imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/G05B7mvYPHBpGu1wP1NK_Q/o.jpg",
            location: Location(
                city: "San Francisco",
                country: "US",
                address2: nil,
                address3: "",
                state: "CA",
                address1: "521A 3rd St",
                zipCode: "94107",
                displayAddress: ["521A 3rd St", "San Francisco, CA 94107"]
            ),
            distance: 760.8230840295653,
            transactions: ["pickup", "delivery"]
        )
    ]
}
