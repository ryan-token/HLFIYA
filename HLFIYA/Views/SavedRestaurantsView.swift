//
//  SavedRestaurantsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import CoreData
import os
import SwiftUI

/// The restaurants saved to one list.
struct SavedRestaurantsView: View {
    /// Observed so deleting a restaurant or renaming the list updates the screen.
    @ObservedObject var list: SavedList

    @State private var isShowingRenameAlert = false
    @Environment(\.managedObjectContext) private var moc

    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "Lists")

    var body: some View {
        let restaurants = list.restaurantsArray

        List {
            ForEach(restaurants, id: \.objectID) { restaurant in
                NavigationLink(restaurant.wrappedName, value: restaurant)
            }
            .onDelete { offsets in
                removeRestaurants(at: offsets, from: restaurants)
            }
        }
        .overlay {
            if restaurants.isEmpty {
                ContentUnavailableView(
                    "No Places Saved",
                    systemImage: "fork.knife",
                    description: Text(
                        "No places added to your \(list.wrappedName) list. Swipe right on a card to add some!"
                    )
                )
            }
        }
        .navigationTitle(list.wrappedName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Rename List", systemImage: "pencil") {
                    isShowingRenameAlert = true
                }
            }
        }
        .renameListAlert(isPresented: $isShowingRenameAlert, list: list)
    }

    private func removeRestaurants(at offsets: IndexSet, from restaurants: [SavedRestaurant]) {
        for index in offsets {
            let restaurant = restaurants[index]
            list.removeFromRestaurants(restaurant)
            moc.delete(restaurant)
        }

        guard moc.hasChanges else { return }
        do {
            try moc.save()
        } catch {
            Self.logger.error("Failed to remove restaurants: \(error.localizedDescription, privacy: .public)")
            moc.rollback()
        }
    }
}
