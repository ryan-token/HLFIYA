//
//  SavedRestaurantsDetailsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

/// The details for a restaurant opened from a saved list.
struct SavedRestaurantsDetailsView: View {
    let restaurantID: String
    let restaurantName: String

    var body: some View {
        RestaurantDetailsList(restaurantID: restaurantID, restaurantName: restaurantName)
    }
}

#Preview {
    NavigationStack {
        SavedRestaurantsDetailsView(restaurantID: "E8RJkjfdcwgtyoPMjQ_Olg", restaurantName: "Four Barrel Coffee")
    }
    .environment(LocationViewModel())
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
