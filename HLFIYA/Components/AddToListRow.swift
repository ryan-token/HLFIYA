//
//  AddToListRow.swift
//  HLFIYA
//

import CoreData
import SwiftUI

/// A button that saves the restaurant to one list.
struct AddToListRow: View {
    let restaurantID: String
    let restaurantName: String
    let list: SavedList
    let model: RestaurantDetailsModel

    @Environment(\.managedObjectContext) private var moc

    var body: some View {
        Button(list.wrappedName) {
            model.add(restaurantID: restaurantID, name: restaurantName, to: list, in: moc)
        }
        .accessibilityLabel("Add to \(list.wrappedName) list")
    }
}
