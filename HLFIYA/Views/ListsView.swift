//
//  ListsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import CoreData
import os
import SwiftUI

/// The person's saved lists of restaurants.
struct ListsView: View {
    @State private var isShowingCreateListSheet = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(fetchRequest: SavedList.allListsFetchRequest, animation: .default)
    private var savedLists: FetchedResults<SavedList>

    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "Lists")

    var body: some View {
        NavigationStack {
            List {
                ForEach(savedLists) { list in
                    NavigationLink(list.wrappedName, value: list)
                }
                .onDelete(perform: removeLists)
            }
            .overlay {
                if savedLists.isEmpty {
                    ContentUnavailableView {
                        Label("No Lists Yet", systemImage: "list.bullet.rectangle")
                    } description: {
                        Text("Create lists to easily save places for later.")
                    } actions: {
                        Button("Create List", systemImage: "plus") {
                            isShowingCreateListSheet = true
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
            .navigationTitle("Lists")
            .navigationDestination(for: SavedList.self) { list in
                SavedRestaurantsView(list: list)
            }
            .navigationDestination(for: SavedRestaurant.self) { restaurant in
                SavedRestaurantsDetailsView(restaurantID: restaurant.wrappedId, restaurantName: restaurant.wrappedName)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Create List", systemImage: "plus") {
                        isShowingCreateListSheet = true
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateListSheet) {
                CreateListSheet()
            }
        }
        .tint(.fuchsia)
    }

    private func removeLists(at offsets: IndexSet) {
        for index in offsets {
            moc.delete(savedLists[index])
        }

        do {
            try moc.save()
        } catch {
            Self.logger.error("Failed to delete lists: \(error.localizedDescription, privacy: .public)")
            moc.rollback()
        }
    }
}

#Preview {
    ListsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
