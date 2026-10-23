//
//  UtilityTests.swift
//  HLFIYATests
//

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

    @Test func openTableLinkOnlyOpensTheWebsite() {
        let link = DeliveryLinks.openTable(restaurantName: "HRD", near: nil)

        #expect(link.appURL == nil)
        #expect(link.webURL?.host() == "www.opentable.com")
    }

    @Test func milesConvertToWholeMeters() {
        #expect(Utils.convertMilesToMeters(miles: 5) == 8047)
    }

    @Test func dayCountIgnoresTimeOfDay() throws {
        let calendar = Calendar(identifier: .gregorian)
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 23)))
        let end = try #require(calendar.date(from: DateComponents(year: 2026, month: 1, day: 3, hour: 1)))

        #expect(calendar.numberOfDaysBetween(start, and: end) == 2)
    }
}
