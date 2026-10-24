//
//  MainSheetContent.swift
//  HLFIYA
//

import SwiftUI

/// The content of whichever sheet the main screen is presenting.
struct MainSheetContent: View {
    let sheet: MainSheet
    let feed: RestaurantFeed
    let filters: FiltersState

    var body: some View {
        switch sheet {
        case .settings:
            SettingsView()
        case .lists:
            ListsView()
        case .categories:
            CategoriesView(feed: feed, filters: filters)
        case .prices:
            PriceView(feed: feed, filters: filters)
        case .location:
            MapView(feed: feed, filters: filters)
        }
    }
}
