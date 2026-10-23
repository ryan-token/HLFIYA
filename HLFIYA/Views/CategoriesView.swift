//
//  CategoriesView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import SwiftUI

/// Chooses which kinds of food to search for, and whether to show only open places.
///
/// Edits a draft; nothing changes until Save, so swiping the sheet away cancels.
struct CategoriesView: View {
    let feed: RestaurantFeed
    let filters: FiltersState

    @State private var selection = CategorySelection()
    @State private var onlyShowOpenNow = false

    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Currently Open", isOn: $onlyShowOpenNow)
                } header: {
                    Text("Hours")
                } footer: {
                    Text("Toggle on to only show places that are currently open. Toggle off to show all places.")
                }

                Section("Types") {
                    ForEach(AllCategories.yelpCategories, id: \.self) { category in
                        Toggle(AllCategories.displayName(for: category), isOn: $selection[isSelected: category])
                    }
                    .toggleStyle(.checkmark)
                }
            }
            .navigationTitle("Choose Categories")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset", systemImage: "arrow.counterclockwise", action: reset)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: save)
                }
            }
        }
        .tint(.fuchsia)
        .onAppear(perform: loadDraft)
    }

    private func loadDraft() {
        selection = filters.categories
        onlyShowOpenNow = filters.openNow
    }

    private func reset() {
        selection.reset()
        onlyShowOpenNow = false
    }

    private func save() {
        filters.applyCategories(selection, openNow: onlyShowOpenNow)
        feed.reload(filters: filters, currentLocation: locationViewModel.location)
        dismiss()
    }
}

#Preview {
    CategoriesView(feed: RestaurantFeed(), filters: FiltersState())
        .environment(LocationViewModel())
}
