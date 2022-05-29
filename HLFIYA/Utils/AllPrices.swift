//
//  AllPrices.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/29/22.
//

import Foundation

struct AllPrices {
    private var allPrices: [String]
    
    init() {
        allPrices = [
            "All Prices",
            "1",
            "2",
            "3",
            "4"
        ]
    }
    
    func getPriceOptions() -> [String] {
        return allPrices
    }
    
    func getFormattedPrice(from price: String) -> String {
        switch price {
        case "All Prices":
            return "All Prices"
        case "1":
            return "$"
        case "2":
            return "$$"
        case "3":
            return "$$$"
        case "4":
            return "$$$$"
        default:
            return "Unknown"
        }
    }
    
    func getPriceNames(from prices: Set<String>) -> String {
        var formattedPricesArray = [String]()
        for price in prices {
            let currentPrice = getFormattedPrice(from: price)
            formattedPricesArray.append(currentPrice)
        }
        
        formattedPricesArray.sort()
        let formattedPricesString = formattedPricesArray.joined(separator: ", ")
        
        return formattedPricesString
    }
}
