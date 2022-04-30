//
//  Business.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import UIKit

struct Businesses: Codable {
    let total: Int?
    let businesses: [Business]?
    let region: Region?
}

struct Business: Identifiable, Codable {
    let id: String
    let rating: Double
    let price: String?
    let phone: String
    let display_phone: String?
    let alias: String?
    let is_closed: Bool
    let categories: [Category]
    let review_count: Int
    let name: String
    let url: String
    let coordinates: Coordinates
    let image_url: String
    let location: Location
    let distance: Double?
    let transactions: [String]?
    
    var x: CGFloat = 0.0 // Card x position
    var y: CGFloat = 0.0 // Card y position
    var degree: Double = 0.0 // Card rotation angle
    
    enum CodingKeys: String, CodingKey {
        case id, rating, price, phone, display_phone, alias, is_closed, categories, review_count, name, url, coordinates, image_url, location, distance, transactions
    }
    
    static var data: [Business] {
        [
            Business(id: "E8RJkjfdcwgtyoPMjQ_Olg", rating: 4.0, price: "$", phone: "+14152520800", display_phone: "", alias: "four-barrel-coffee-san-francisco", is_closed: false, categories: [Category(alias: "coffee", title: "Coffee & Tea")], review_count: 1738, name: "Four Barrel Coffee", url: "https://www.yelp.com/biz/four-barrel-coffee-san-francisco", coordinates: Coordinates(latitude: 37.7670169511878, longitude: -122.42184275), image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/MmgtASP3l_t4tPCL1iAsCg/o.jpg", location: Location(city: "San Francisco", country: "US", address2: "", address3: "", state: "CA", address1: "375 Valencia St", zip_code: "94103", display_address: [""]), distance: 1604.23, transactions: ["pickup", "delivery"]),
            
            Business(id: "Xg-FyjVKAN70LO4u4Z1ozg", rating: 4.5, price: "$$", phone: "+14153917117", display_phone: "(415) 391-7117", alias: "hog-island-oyster-san-francisco-2", is_closed: false, categories: [Category(alias: "seafood", title: "Seafood"), Category(alias: "seafoodmarkets", title: "Seafood Markets"), Category(alias: "raw_food", title: "Live/Raw Food")], review_count: 6352, name: "Hog Island Oyster", url: "https://www.yelp.com/biz/hog-island-oyster-san-francisco-2?adjust_creative=UfehWLhDVrB4o_GfgvAOQw&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=UfehWLhDVrB4o_GfgvAOQw", coordinates: Coordinates(latitude: 37.795831, longitude: -122.393303), image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg", location: Location(city: "San Francisco", country: "US", address2: "", address3: "Shop 11", state: "CA", address1: "1 Ferry Bldg", zip_code: "94111", display_address: ["1 Ferry Bldg", "Shop 11", "San Francisco, CA 94111"]), distance: 1154.8167382059307, transactions: ["pickup"]),
            
            Business(id: "bUr4iq2mKKiBOu2HKynylg", rating: 4.0, price: "$$", phone: "+14155432355", display_phone: "(415) 543-2355", alias: "hrd-san-francisco-4", is_closed: false, categories: [Category(alias: "korean", title: "Korean"), Category(alias: "asianfusion", title: "Asian Fusion"), Category(alias: "mexican", title: "Mexican")], review_count: 2518, name: "HRD", url: "https://www.yelp.com/biz/hrd-san-francisco-4?adjust_creative=UfehWLhDVrB4o_GfgvAOQw&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=UfehWLhDVrB4o_GfgvAOQw", coordinates: Coordinates(latitude: 37.7811065758548, longitude: -122.395329724426), image_url: "https://s3-media1.fl.yelpcdn.com/bphoto/G05B7mvYPHBpGu1wP1NK_Q/o.jpg", location: Location(city: "San Francisco", country: "US", address2: nil, address3: "", state: "CA", address1: "521A 3rd St", zip_code: "94107", display_address: ["521A 3rd St", "San Francisco, CA 94107"]), distance: 760.8230840295653, transactions: ["pickup", "delivery"])
        ]
    }
    
    static var emptyBusinesses: [Business] {
        [
            Business(id: "", rating: 0.0, price: "", phone: "", display_phone: "", alias: "", is_closed: false, categories: [Category(alias: "", title: "")], review_count: 0, name: "No Results", url: "#", coordinates: Coordinates(latitude: 0.00, longitude: 0.00), image_url: "#", location: Location(city: "", country: "", address2: "", address3: "", state: "", address1: "", zip_code: "", display_address: [""]), distance: 0.00, transactions: ["", ""])
        ]
    }
    
}

extension Business {
    struct Category: Codable {
        let alias: String
        let title: String
    }
    
    struct Coordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    struct Location: Codable {
        let city: String
        let country: String
        let address2: String?
        let address3: String?
        let state: String
        let address1: String?
        let zip_code: String
        let display_address: [String]?
    }
}

extension Businesses {
    struct Region: Codable {
        let center: Center
    }
    
    struct Center: Codable {
        let longitude: Double
        let latitude: Double
    }
}
