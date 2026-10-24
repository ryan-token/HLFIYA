//
//  FilterSelectionTests.swift
//  HLFIYATests
//

@testable import HLFIYA
import Testing

struct FilterSelectionTests {
    @Test func selectingACategoryReplacesAllFood() {
        var selection = CategorySelection()
        selection[isSelected: "pizza"] = true

        #expect(selection.categories == ["pizza"])
        #expect(selection.summary == "Pizza")
    }

    @Test func deselectingTheLastCategoryRestoresAllFood() {
        var selection = CategorySelection(categories: ["pizza"])
        selection[isSelected: "pizza"] = false

        #expect(selection.categories == [AllCategories.allFood])
    }

    @Test func choosingAllFoodClearsOtherCategories() {
        var selection = CategorySelection(categories: ["pizza", "sushi"])
        selection.toggle(AllCategories.allFood)

        #expect(selection.categories == [AllCategories.allFood])
    }

    @Test func selectingEveryCategoryBecomesAllFood() {
        var selection = CategorySelection()
        for category in AllCategories.yelpCategories where category != AllCategories.allFood {
            selection.toggle(category)
        }

        #expect(selection.categories == [AllCategories.allFood])
    }

    @Test func categorySummaryUsesDisplayOrder() {
        let selection = CategorySelection(categories: ["thai", "burgers", "pizza"])
        #expect(selection.summary == "Burgers and 2 More")
    }

    @Test func pricesConvertToTheYelpParameter() {
        var selection = PriceSelection()
        #expect(selection.apiValue == "1,2,3,4")

        selection.toggle("3")
        selection.toggle("1")
        #expect(selection.apiValue == "1,3")
        #expect(selection.prices == ["1", "3"])
    }

    @Test func selectingEveryPriceBecomesAllPrices() {
        var selection = PriceSelection()
        for price in ["1", "2", "3", "4"] {
            selection.toggle(price)
        }

        #expect(selection.prices == [AllPrices.allPrices])
    }
}
