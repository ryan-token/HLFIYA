//
//  RestaurantFetcher.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import Foundation

/// Fetches restaurants from the Yelp Fusion API and caches the responses on disk.
nonisolated enum BusinessFetcher {
    private static let yelpKey = Bundle.main.infoDictionary?["YelpAPIKey"] as? String ?? ""
    private static let baseURL = URL(string: "https://api.yelp.com/v3/businesses")

    /// Yelp categories that describe shops rather than places to eat.
    private static let excludedCategoryAliases: Set<String> = [
        "grocery", "intlgrocery", "ethicgrocery", "healthmarkets", "organic_stores", "convenience", "giftshops"
    ]

    enum BusinessFetcherError: Error {
        case invalidURL
    }

    /// Searches for restaurants, returning them shuffled with shops filtered out.
    /// The cache holds the filtered list, so restored results match live ones.
    @concurrent
    static func getBusinesses(for search: BusinessSearch) async throws -> [Business] {
        let response = try await fetch(Businesses.self, from: try searchURL(for: search))
        let restaurants = (response.businesses ?? []).filter { business in
            !(business.categories ?? []).contains { excludedCategoryAliases.contains($0.alias) }
        }
        Utils.writeBusinessesCache(Businesses(total: response.total, businesses: restaurants, region: response.region))

        return restaurants.shuffled()
    }

    /// Returns the full details, including photos and hours, for one business,
    /// from the on-disk cache when they've been fetched before.
    @concurrent
    static func getBusiness(id: String) async throws -> BusinessDetails {
        if let cached = Utils.getLocalYelpCacheForBusiness(id: id) {
            return cached
        }
        guard let url = baseURL?.appending(path: id) else { throw BusinessFetcherError.invalidURL }

        let details = try await fetch(BusinessDetails.self, from: url)
        Utils.writeBusinessDetailsCache(details)
        return details
    }

    /// Builds the business search URL. Internal so tests can verify the query.
    static func searchURL(for search: BusinessSearch) throws -> URL {
        guard let searchURL = baseURL?.appending(path: "search") else { throw BusinessFetcherError.invalidURL }

        var queryItems = [
            URLQueryItem(name: "latitude", value: String(search.latitude)),
            URLQueryItem(name: "longitude", value: String(search.longitude)),
            URLQueryItem(name: "radius", value: String(search.radiusInMeters)),
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "categories", value: search.categories.sorted().joined(separator: ",")),
            URLQueryItem(name: "price", value: search.prices.isEmpty ? "1,2,3,4" : search.prices)
        ]

        if search.openNow {
            queryItems.append(URLQueryItem(name: "open_now", value: "true"))
        }

        return searchURL.appending(queryItems: queryItems)
    }

    private static func fetch<Value: Decodable>(_ type: Value.Type, from url: URL) async throws -> Value {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(yelpKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder.yelp.decode(type, from: data)
    }
}
