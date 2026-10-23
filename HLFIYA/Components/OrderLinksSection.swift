//
//  OrderLinksSection.swift
//  HLFIYA
//

import SwiftUI

/// Links that search delivery and reservation services for the restaurant.
struct OrderLinksSection: View {
    let restaurantName: String
    let yelpURL: String?

    @Environment(LocationViewModel.self) private var locationViewModel

    var body: some View {
        Section("Order") {
            ExternalLinkRow(title: "Search DoorDash", link: DeliveryLinks.doorDash(restaurantName: restaurantName))
            ExternalLinkRow(title: "Search Uber Eats", link: DeliveryLinks.uberEats(restaurantName: restaurantName))
            ExternalLinkRow(
                title: "Search OpenTable",
                link: DeliveryLinks.openTable(restaurantName: restaurantName, near: locationViewModel.location)
            )
            ExternalLinkRow(title: "See More on Yelp", link: yelpLink)
        }
    }

    private var yelpLink: DeliveryLinks.Link {
        let webURL = yelpURL.flatMap(URL.init(string:)) ?? URL(string: "https://www.yelp.com")
        return DeliveryLinks.Link(appURL: nil, webURL: webURL)
    }
}
