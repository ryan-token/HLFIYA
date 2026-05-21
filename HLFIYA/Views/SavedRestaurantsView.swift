//
//  SavedRestaurantsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct SavedRestaurantsView: View {
    let list: SavedList

    @State private var isShowingUpdateListNameAlert = false
    @State private var newListName = ""
    @Environment(\.managedObjectContext) private var moc

    var body: some View {
        ZStack {
            Group {
                if list.restaurantsArray.isEmpty {
                    ContentUnavailableView(
                        "No Places Saved",
                        systemImage: "fork.knife",
                        description: Text("No places added to your \(list.wrappedName) list. Swipe right on a card to add some!")
                    )
                } else {
                    List {
                        ForEach(list.restaurantsArray) { restaurant in
                            NavigationLink {
                                SavedRestaurantsDetailsView(restaurantId: restaurant.wrappedId)
                            } label: {
                                Text(restaurant.wrappedName)
                            }
                        }
                        .onDelete { offsets in
                            removeRestaurantFromList(at: offsets, from: list)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 20)
                    }
                }
            }

            VStack {
                Spacer()
                GlassButton(action: { isShowingUpdateListNameAlert = true }) {
                    Label("Change List Name", systemImage: "pencil")
                        .foregroundStyle(.fuchsia)
                        .padding(10)
                }
                .font(.headline)
            }
        }
        .onAppear {
            newListName = list.name ?? ""
        }
        .alert("Change List Name", isPresented: $isShowingUpdateListNameAlert) {
            TextField("New List Name", text: $newListName)
                .textInputAutocapitalization(.words)
            Button("Change List Name") { updateListNameViaAlert(list: list) }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle(list.wrappedName)
    }

    private func removeRestaurantFromList(at offsets: IndexSet, from list: SavedList) {
        for index in offsets.sorted() {
            let restaurantToDelete = list.restaurantsArray[index]
            list.removeFromRestaurants(restaurantToDelete)
            moc.delete(restaurantToDelete)
        }

        if moc.hasChanges {
            try? moc.save()
        }
    }

    private func updateListNameViaAlert(list: SavedList) {
        guard !newListName.isEmpty else { return }
        list.name = newListName
        try? moc.save()
    }
}
