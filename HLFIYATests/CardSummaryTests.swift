//
//  CardSummaryTests.swift
//  HLFIYATests
//

@testable import HLFIYA
import Testing

struct CardSummaryTests {
    @Test func missingDetailsBecomeEmpty() {
        let summary = CardSummary(business: .fixture(id: "Taco Spot"))

        #expect(summary == CardSummary(name: "Taco Spot", rating: 0, price: "", category: ""))
    }

    @Test func usesTheFirstCategory() {
        let summary = CardSummary(business: .fixture(id: "Taco Spot", categoryAliases: ["Tacos", "Bars"]))

        #expect(summary.category == "Tacos")
    }

    @Test func accessibilityDescriptionSkipsEmptyDetails() {
        let summary = CardSummary(name: "Taco Spot", rating: 4.5, price: "$$", category: "")

        #expect(summary.accessibilityDescription.contains("Taco Spot"))
        #expect(summary.accessibilityDescription.contains("2 dollar signs"))
        #expect(!summary.accessibilityDescription.hasSuffix(", "))
    }
}
