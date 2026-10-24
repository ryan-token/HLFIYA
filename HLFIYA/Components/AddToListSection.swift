//
//  AddToListSection.swift
//  HLFIYA
//

import CoreData
import SwiftUI

/// Buttons that save the restaurant to one of the person's lists, or create a new list.
struct AddToListSection: View {
    let restaurantID: String
    let restaurantName: String
    let model: RestaurantDetailsModel

    @FetchRequest(fetchRequest: SavedList.allListsFetchRequest)
    private var savedLists: FetchedResults<SavedList>

    var body: some View {
        Section("Add to List") {
            ForEach(savedLists) { list in
                AddToListRow(restaurantID: restaurantID, restaurantName: restaurantName, list: list, model: model)
            }

            Button("Create List", systemImage: "plus.square.fill") {
                model.isShowingCreateListSheet = true
            }
            .font(.headline)
        }
    }
}
