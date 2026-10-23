//
//  DeliveryLinks.swift
//  HLFIYA
//

import CoreLocation
import Foundation

/// Builds the links that search delivery and reservation services for a restaurant.
nonisolated enum DeliveryLinks {
    /// An app deep link with a website to open when the app isn't installed.
    struct Link: Equatable {
        let appURL: URL?
        let webURL: URL?
    }

    static func doorDash(restaurantName: String) -> Link {
        let path = "search/store/\(encoded(restaurantName))/?event_type=search"
        return Link(appURL: URL(string: "doordash:///\(path)"), webURL: URL(string: "https://www.doordash.com/\(path)"))
    }

    static func uberEats(restaurantName: String) -> Link {
        let path = "search?diningMode=DELIVERY&q=\(encoded(restaurantName))&sc=SEARCH_SUGGESTION&vertical=ALL"
        return Link(appURL: URL(string: "ubereats://\(path)"), webURL: URL(string: "https://www.ubereats.com/\(path)"))
    }

    /// OpenTable's app doesn't accept search links, so this always opens the website.
    static func openTable(restaurantName: String, near location: CLLocation?, at date: Date = .now) -> Link {
        let name = encoded(restaurantName)
        let dateTime = date.formatted(
            .iso8601.year().month().day().dateTimeSeparator(.standard).time(includingFractionalSeconds: false)
        )
        let coordinate = location.map {
            "&latitude=\($0.coordinate.latitude)&longitude=\($0.coordinate.longitude)"
        } ?? ""
        let path = "s?dateTime=\(dateTime)&covers=2\(coordinate)&term=\(name)"
            + "&shouldUseLatLongSearch=true&sortBy=web_conversion"
            + "&originalTerm=\(name)&intentModifiedTerm=\(name)&queryUnderstandingType=default"
        return Link(appURL: nil, webURL: URL(string: "https://www.opentable.com/\(path)"))
    }

    /// RFC 3986's unreserved characters. Everything else is escaped, so names like
    /// "Ben & Jerry's" or "Pho 24/7" stay one query value or path segment.
    private static let unreservedCharacters = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )

    private static func encoded(_ name: String) -> String {
        name.addingPercentEncoding(withAllowedCharacters: unreservedCharacters) ?? name
    }
}
