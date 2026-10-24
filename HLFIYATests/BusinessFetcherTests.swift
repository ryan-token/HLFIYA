//
//  BusinessFetcherTests.swift
//  HLFIYATests
//

import CoreLocation
import Foundation
@testable import HLFIYA
import Testing

struct BusinessFetcherTests {
    private func queryItems(of url: URL) -> [String: String] {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
    }

    @Test func searchURLIncludesEveryFilter() throws {
        let search = BusinessSearch(
            coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: -122.25),
            radiusInMeters: 8047,
            categories: ["sushi", "pizza"],
            prices: "1,2",
            openNow: true
        )

        let url = try BusinessFetcher.searchURL(for: search)
        let query = queryItems(of: url)

        #expect(url.path() == "/v3/businesses/search")
        #expect(query["latitude"] == "37.5")
        #expect(query["longitude"] == "-122.25")
        #expect(query["radius"] == "8047")
        #expect(query["limit"] == "50")
        #expect(query["categories"] == "pizza,sushi")
        #expect(query["price"] == "1,2")
        #expect(query["open_now"] == "true")
    }

    @Test func searchURLOmitsOpenNowWhenOff() throws {
        let search = BusinessSearch(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            radiusInMeters: 1000,
            categories: ["food"],
            prices: "",
            openNow: false
        )

        let query = queryItems(of: try BusinessFetcher.searchURL(for: search))

        #expect(query["open_now"] == nil)
        #expect(query["price"] == "1,2,3,4")
    }

    @Test func removingShopsKeepsOnlyPlacesToEat() {
        let businesses = [
            Business.fixture(id: "pizza", categoryAliases: ["pizza"]),
            Business.fixture(id: "deli", categoryAliases: ["delis", "grocery"]),
            Business.fixture(id: "corner", categoryAliases: ["convenience"]),
            Business.fixture(id: "uncategorized")
        ]

        let restaurants = BusinessFetcher.removingShops(from: businesses)

        #expect(restaurants.map(\.id) == ["pizza", "uncategorized"])
    }

    /// Caches written before the camelCase rename must still decode.
    @Test func decodesYelpSnakeCaseJSON() throws {
        let json = Data("""
        {
            "id": "abc",
            "name": "Taqueria",
            "display_phone": "(555) 555-5555",
            "review_count": 42,
            "image_url": "https://example.com/photo.jpg",
            "is_closed": false,
            "location": {
                "city": "Oakland",
                "country": "US",
                "state": "CA",
                "zip_code": "94612",
                "display_address": ["1 Main St", "Oakland, CA 94612"]
            }
        }
        """.utf8)

        let business = try JSONDecoder.yelp.decode(Business.self, from: json)

        #expect(business.displayPhone == "(555) 555-5555")
        #expect(business.reviewCount == 42)
        #expect(business.imageURL == "https://example.com/photo.jpg")
        #expect(business.location?.zipCode == "94612")
        #expect(business.location?.displayAddress == ["1 Main St", "Oakland, CA 94612"])
    }

    @Test func cachedBusinessesRoundTrip() throws {
        let response = Businesses(total: 3, businesses: Business.data, region: nil)
        let data = try JSONEncoder.yelp.encode(response)
        let decoded = try JSONDecoder.yelp.decode(Businesses.self, from: data)

        #expect(decoded == response)
        // The cache keeps Yelp's own key names.
        #expect(String(bytes: data, encoding: .utf8)?.contains("\"image_url\"") == true)
    }
}
