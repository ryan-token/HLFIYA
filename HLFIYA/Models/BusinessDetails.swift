//
//  BusinessDetail.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import UIKit

struct BusinessDetails: Identifiable, Codable {
    // same as the Business struct
    var id: String?
    var rating: Double?
    var price: String?
    var phone: String?
    var display_phone: String?
    var alias: String?
    var is_closed: Bool?
    var categories: [Category]?
    var review_count: Int?
    var name: String?
    var url: String?
    var coordinates: Coordinates?
    var image_url: String?
    var location: Location?
    var distance: Double?
    var transactions: [String]?
    
    // specific to BusinessDetails
    var is_claimed: Bool?
    var photos: [String]?
    var hours: [Hours]?
    var special_hours: [SpecialHours]?
    
    
    static var data: BusinessDetails {
        BusinessDetails(
            id: "E8RJkjfdcwgtyoPMjQ_Olg",
            rating: 4.0,
            price: "$",
            phone: "+14152520800",
            display_phone: "",
            alias: "four-barrel-coffee-san-francisco",
            is_closed: false,
            categories: [
                Category(alias: "coffee", title: "Coffee & Tea")
            ],
            review_count: 1738,
            name: "Four Barrel Coffee",
            url: "https://www.yelp.com/biz/four-barrel-coffee-san-francisco",
            coordinates: Coordinates(latitude: 37.7670169511878, longitude: -122.42184275),
            image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/MmgtASP3l_t4tPCL1iAsCg/o.jpg",
            location: Location(city: "San Francisco", country: "US", address2: "", address3: "", state: "CA", address1: "375 Valencia St", zip_code: "94103", display_address: [""]),
            distance: 1604.23,
            transactions: ["pickup", "delivery"],
            
            is_claimed: false,
            photos: [
                "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg",
                "https://s3-media4.fl.yelpcdn.com/bphoto/ahmWdH7P0UIc4lM1c8zhcQ/o.jpg",
                "https://s3-media2.fl.yelpcdn.com/bphoto/BlG7QLi2mseijvxFnAb5yg/o.jpg"
            ],
            hours: [
                Hours(open: [
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 0),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 1),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 2),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 3),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 4),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 5),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 6),
                ], hours_type: "Regular", is_open_now: true)
            ],
            
            special_hours: [
                SpecialHours(date: "2022-11-24", is_closed: true, start: nil, end: nil, is_overnight: nil),
                SpecialHours(date: "2022-12-24", is_closed: nil, start: "1100", end: "1500", is_overnight: false)
            ]
        )
    }
    
    static var emptyBusiness: BusinessDetails {
        BusinessDetails(
            id: "E8RJkjfdcwgtyoPMjQ_Olg",
            rating: 0.0,
            price: "$",
            phone: "",
            display_phone: "",
            alias: "",
            is_closed: false,
            categories: [
                Category(alias: "", title: "")
            ],
            review_count: 0,
            name: "",
            url: "",
            coordinates: Coordinates(latitude: 37.7670169511878, longitude: -122.42184275),
            image_url: "",
            location: Location(city: "", country: "", address2: "", address3: "", state: "", address1: "", zip_code: "", display_address: [""]),
            distance: 0.00,
            transactions: [""],
            
            is_claimed: false,
            photos: [
                ""
            ],
            hours: [
                Hours(open: [
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 0),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 1),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 2),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 3),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 4),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 5),
                    Hour(is_overnight: false, start: "1100", end: "2000", day: 6),
                ], hours_type: "Regular", is_open_now: true)
            ]
        )
    }
}

extension BusinessDetails {
    struct Category: Codable, Hashable {
        var alias: String?
        var title: String?
    }
    
    struct Coordinates: Codable {
        var latitude: Double?
        var longitude: Double?
    }
    
    struct Location: Codable {
        var city: String?
        var country: String?
        var address2: String?
        var address3: String?
        var state: String?
        var address1: String?
        var zip_code: String?
        var display_address: [String]?
    }
    
    struct Hours: Codable, Hashable {
        var open: [Hour]?
        var hours_type: String?
        var is_open_now: Bool?
    }
    
    struct Hour: Codable, Hashable {
        var is_overnight: Bool?
        var start: String?
        var end: String?
        var day: Int?
    }
    
    struct SpecialHours: Codable {
        var date: String?
        var is_closed: Bool?
        var start: String?
        var end: String?
        var is_overnight: Bool?
    }
}
