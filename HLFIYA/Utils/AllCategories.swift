//
//  AllCategories.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import Foundation

struct AllCategories {
    private var allCategories: [String]
    
    init() {
        allCategories = [
            "food",
            "beer_and_wine",
            "breakfast_brunch",
            "breweries",
            "british",
            "burgers",
            "chinese",
            "cocktailbars",
            "coffee",
            "comfortfood",
            "hotdogs",
            "foodtrucks",
            "french",
            "german",
            "greek",
            "indpak",
            "italian",
            "japanese",
            "korean",
            "mexican",
            "mideastern",
            "pizza",
            "seafood",
            "steak",
            "sushi",
            "thai",
            "vegan",
            "vegetarian",
            "wineries"
        ]
    }
    
    func getYelpCategories() -> [String] {
        return allCategories
    }
    
    func getFormattedCategory(from yelpCategory: String) -> String {
        switch yelpCategory {
        case "food":
            return "All Food"
        case "beer_and_wine":
            return "Beer, Wine, & Spirits"
        case "breakfast_brunch":
            return "Breakfast & Brunch"
        case "breweries":
            return "Breweries"
        case "british":
            return "British"
        case "burgers":
            return "Burgers"
        case "chinese":
            return "Chinese"
        case "cocktailbars":
            return "Cocktail Bars"
        case "coffee":
            return "Coffee & Tea"
        case "comfortfood":
            return "Comfort Food"
        case "hotdogs":
            return "Fast Food"
        case "foodtrucks":
            return "Food Trucks"
        case "french":
            return "French"
        case "german":
            return "German"
        case "greek":
            return "Greek"
        case "indpak":
            return "Indian"
        case "italian":
            return "Italian"
        case "japanese":
            return "Japanese"
        case "korean":
            return "Korean"
        case "mexican":
            return "Mexican"
        case "mideastern":
            return "Middle Eastern"
        case "pizza":
            return "Pizza"
        case "seafood":
            return "Seafood"
        case "steak":
            return "Steakhouses"
        case "sushi":
            return "Sushi"
        case "thai":
            return "Thai"
        case "vegan":
            return "Vegan"
        case "vegetarian":
            return "Vegetarian"
        case "wineries":
            return "Wineries"
        default:
            return "Unknown"
        }
    }
}
