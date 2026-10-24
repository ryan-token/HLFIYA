//
//  AllCategories.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import Foundation

/// The Yelp category aliases the app offers as filters, in display order.
nonisolated enum AllCategories {
    /// The alias that means "every food category".
    static let allFood = "food"

    /// Every selectable Yelp category alias, in the order they appear in the picker.
    static let yelpCategories = displayNames.map(\.alias)

    private static let displayNames: [(alias: String, name: String)] = [
        ("food", "All Food"),
        ("beer_and_wine", "Beer, Wine, & Spirits"),
        ("breakfast_brunch", "Breakfast & Brunch"),
        ("breweries", "Breweries"),
        ("british", "British"),
        ("burgers", "Burgers"),
        ("chinese", "Chinese"),
        ("cocktailbars", "Cocktail Bars"),
        ("coffee", "Coffee & Tea"),
        ("comfortfood", "Comfort Food"),
        ("desserts", "Desserts"),
        ("hotdogs", "Fast Food"),
        ("foodtrucks", "Food Trucks"),
        ("french", "French"),
        ("german", "German"),
        ("greek", "Greek"),
        ("icecream", "Ice Cream"),
        ("indpak", "Indian"),
        ("italian", "Italian"),
        ("japanese", "Japanese"),
        ("korean", "Korean"),
        ("mexican", "Mexican"),
        ("mideastern", "Middle Eastern"),
        ("pizza", "Pizza"),
        ("seafood", "Seafood"),
        ("sportsbars", "Sports Bars"),
        ("steak", "Steakhouses"),
        ("sushi", "Sushi"),
        ("thai", "Thai"),
        ("vegan", "Vegan"),
        ("vegetarian", "Vegetarian"),
        ("wineries", "Wineries")
    ]

    /// Returns the user-facing name for a Yelp category alias.
    static func displayName(for alias: String) -> String {
        displayNames.first { $0.alias == alias }?.name ?? "Unknown"
    }

    /// Returns the given aliases sorted into picker order, so summaries are stable.
    static func sortedInDisplayOrder(_ aliases: Set<String>) -> [String] {
        yelpCategories.filter(aliases.contains)
    }
}
