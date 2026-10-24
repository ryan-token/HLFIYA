//
//  RestaurantDetailsList.swift
//  HLFIYA
//

import SwiftUI

/// A restaurant's photos, details, ordering links, and list actions.
///
/// Shared by the sheet that opens after a right swipe and by saved lists.
struct RestaurantDetailsList: View {
    let restaurantID: String
    let restaurantName: String

    @State private var model = RestaurantDetailsModel()

    var body: some View {
        List {
            if model.loadFailed {
                Text("😕 Couldn't load the details for this place.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }

            if let details = model.details {
                RestaurantSummarySection(
                    rating: details.rating ?? 0,
                    reviewCount: details.reviewCount,
                    price: details.price ?? "",
                    categories: details.categories?.compactMap(\.title) ?? []
                )

                RestaurantPhotosSection(photos: details.photoURLs)
            } else if !model.loadFailed {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }

            AddToListSection(restaurantID: restaurantID, restaurantName: restaurantName, model: model)

            if let details = model.details {
                OrderLinksSection(restaurantName: details.name ?? restaurantName, yelpURL: details.url)

                RestaurantInfoSection(details: RestaurantInfo(details))
            }

            PoweredByYelpRow()
        }
        .navigationTitle(model.details?.name ?? restaurantName)
        .toolbarTitleDisplayMode(.large)
        .task(id: restaurantID) {
            await model.load(restaurantID: restaurantID)
        }
        .alert(model.listAlert?.title(restaurantName: restaurantName) ?? "", item: $model.listAlert) { _ in }
        .sheet(isPresented: $model.isShowingCreateListSheet) {
            CreateListSheet()
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailsList(restaurantID: "E8RJkjfdcwgtyoPMjQ_Olg", restaurantName: "Four Barrel Coffee")
    }
    .environment(LocationViewModel())
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
