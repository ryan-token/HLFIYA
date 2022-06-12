//
//  BusinessFetcher.swift
//  HLFIYA
//
//  Created by Ryan Token on 2/22/22.
//

import Foundation

struct BusinessFetcher {
    enum BusinessFetcherError: Error {
        case invalidURL
        case missingData
    }
    
    // radius is in meters
    static func getBusinessesNear(latitude: Double, longitude: Double, radius: Int, categories: Set<String>, prices: String) async throws -> [Business] {
        var userCategories: Set = ["food"]
        if categories == userCategories { userCategories = ["food"] } else { userCategories = categories }
        let formattedCategories = userCategories.joined(separator: ",")
        
        var userPrice = ""
        if prices == "" { userPrice = "1, 2, 3, 4" } else { userPrice = prices }
        
        print("getting businesses near \(latitude), \(longitude), within a radius of \(radius) meters")
        let endpoint = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)&limit=50&categories=\(formattedCategories)&price=\(userPrice)"
        let cleanEndpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        print(cleanEndpoint)
        
        guard let url = URL(string: cleanEndpoint) else {
            throw BusinessFetcherError.invalidURL
        }
        
        let yelpKey = "BeQ7EhHbnd1qfNSPjT5t03BrHmtMLaYdt2byyLfPSHD8D9rP35YZ_1tU9b8TCeL7B3rROt4TVIwnAOyMFckxe_7o0xyemhWhvRJH61BuScIgnPHIjt0D99RTYkPsYXYx"
        
        var yelpRequest = URLRequest(url: url)
        yelpRequest.httpMethod = "GET"
        yelpRequest.setValue("Bearer \(yelpKey)", forHTTPHeaderField: "Authorization")
        yelpRequest.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")

        // Use the async variant of URLSession to fetch data
        // Code might suspend here
        let (data, _) = try await URLSession.shared.data(for: yelpRequest)

        // Parse the JSON data
        let response = try JSONDecoder().decode(Businesses.self, from: data)
        let businesses = response.businesses
        let shuffledBusinesses = businesses?.shuffled()
        
        HapticGenerator.playSuccessHaptic()
        return shuffledBusinesses ?? Business.emptyBusinesses
    }
    
    static func getBusiness(id: String) async throws -> BusinessDetails {
        print("getting business with ID \(id)")
        let endpoint = "https://api.yelp.com/v3/businesses/\(id)"
        let cleanEndpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        print(cleanEndpoint)
        
        guard let url = URL(string: cleanEndpoint) else {
            throw BusinessFetcherError.invalidURL
        }
        
        let yelpKey = "BeQ7EhHbnd1qfNSPjT5t03BrHmtMLaYdt2byyLfPSHD8D9rP35YZ_1tU9b8TCeL7B3rROt4TVIwnAOyMFckxe_7o0xyemhWhvRJH61BuScIgnPHIjt0D99RTYkPsYXYx"
        
        var yelpRequest = URLRequest(url: url)
        yelpRequest.httpMethod = "GET"
        yelpRequest.setValue("Bearer \(yelpKey)", forHTTPHeaderField: "Authorization")
        yelpRequest.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")

        // Use the async variant of URLSession to fetch data
        // Code might suspend here
        let (data, _) = try await URLSession.shared.data(for: yelpRequest)

        // Parse the JSON data
        let businessDetails = try JSONDecoder().decode(BusinessDetails.self, from: data)
        
        return businessDetails
    }
}
