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
            "breakfast_brunch",
            "british",
            "burgers",
            "chinese",
            "comfortfood",
            "fooddeliveryservices",
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
            "vegetarian"
        ]
    }
    
    func getYelpCategories() -> [String] {
        return allCategories
    }
    
    func getFormattedCategory(from yelpCategory: String) -> String {
        switch yelpCategory {
        case "food":
            return "All Food"
        case "breakfast_brunch":
            return "Breakfast & Brunch"
        case "british":
            return "British"
        case "burgers":
            return "Burgers"
        case "chinese":
            return "Chinese"
        case "comfortfood":
            return "Comfort Food"
        case "fooddeliveryservices":
            return "Delivery Options"
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
        default:
            return "Unknown"
        }
    }
}
