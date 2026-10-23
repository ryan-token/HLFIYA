//
//  UtilityTests.swift
//  HLFIYATests
//

import CoreLocation
import Foundation
@testable import HLFIYA
import Testing

struct UtilityTests {
    @Test func swipeTallyRanksByCountThenName() {
        let names = ["Pizza Place", " Taco Spot ", "Taco Spot", "Burger Bar", "Pizza Place", "Taco Spot"]

        let tallies = SwipeTally.top(2, from: names)

        #expect(tallies == [
            SwipeTally(name: "Taco Spot", count: 3),
            SwipeTally(name: "Pizza Place", count: 2)
        ])
    }

    @Test func doorDashLinkKeepsTheNameInOnePathSegment() {
        let link = DeliveryLinks.doorDash(restaurantName: "Pho 24/7")

        #expect(link.appURL?.absoluteString == "doordash:///search/store/Pho%2024%2F7/?event_type=search")
        #expect(link.webURL?.absoluteString == "https://www.doordash.com/search/store/Pho%2024%2F7/?event_type=search")
    }

    @Test func uberEatsLinkKeepsTheNameInOneQueryValue() throws {
        let link = DeliveryLinks.uberEats(restaurantName: "Ben & Jerry's")
        let url = try #require(link.webURL)
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        #expect(queryItems.first { $0.name == "q" }?.value == "Ben & Jerry's")
        #expect(!queryItems.contains { $0.name.contains("Jerry") })
    }

    @Test func openTableLinkSearchesNearbyAtLocalTime() throws {
        let timeZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
        // 2026-07-01 19:30 in Los Angeles, which is 02:30 the next day in UTC.
        let date = Date(timeIntervalSince1970: 1_782_959_400)

        let link = DeliveryLinks.openTable(
            restaurantName: "Ben & Jerry's",
            near: CLLocation(latitude: 37.5, longitude: -122.25),
            at: date,
            in: timeZone
        )
        let url = try #require(link.webURL)
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let query = Dictionary(queryItems.map { ($0.name, $0.value ?? "") }) { first, _ in first }

        #expect(link.appURL == nil)
        #expect(query["dateTime"] == "2026-07-01T19:30:00")
        #expect(query["term"] == "Ben & Jerry's")
        #expect(query["latitude"] == "37.5")
    }

    @Test func dayCountIgnoresTimeOfDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 23)))
        let end = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 1)))

        #expect(calendar.numberOfDaysBetween(start, and: end) == 2)
    }
}
