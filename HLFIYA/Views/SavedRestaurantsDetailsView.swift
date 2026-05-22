//
//  SavedRestaurantsDetailsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/11/22.
//

import SwiftUI

struct SavedRestaurantsDetailsView: View {
    var restaurantId: String

    @State private var currentRestaurant = BusinessDetails()
    @State private var listTappedName = ""
    @State private var isShowingCreateListSheet = false
    @State private var isShowingAddedToListAlert = false
    @State private var isShowingAddedToListErrorAlert = false
    @State private var isShowingDuplicateAlert = false
    @State private var selectedTab = 1
    @State private var apiError = false

    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(fetchRequest: SavedList.allListsFetchRequest)
    private var savedLists: FetchedResults<SavedList>

    var body: some View {
        List {
            RestaurantSummarySection(restaurant: currentRestaurant)

            RestaurantPhotosSection(
                photos: currentRestaurant.photos ?? [],
                selectedTab: $selectedTab
            )

            AddToListSection(
                savedLists: savedLists,
                onAddToList: { list in
                    listTappedName = list.wrappedName
                    addToList(list: list, id: currentRestaurant.id ?? "", name: currentRestaurant.name ?? "")
                },
                onCreateList: { isShowingCreateListSheet.toggle() }
            )

            OrderLinksSection(restaurant: currentRestaurant)

            RestaurantInfoSection(restaurant: currentRestaurant)

            PoweredByYelpRow()
        }
        .navigationTitle(currentRestaurant.name ?? "")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadBusinessDetails()
        }
        .alert("Added \(currentRestaurant.name ?? "") to your \(listTappedName) list", isPresented: $isShowingAddedToListAlert) {}
        .alert("Error adding \(currentRestaurant.name ?? "") to your \(listTappedName) list", isPresented: $isShowingAddedToListErrorAlert) {}
        .alert("\(currentRestaurant.name ?? "") is already in your \(listTappedName) list!", isPresented: $isShowingDuplicateAlert) {}
        .popover(isPresented: $isShowingCreateListSheet) {
            CreateListSheet()
        }
    }

    private func loadBusinessDetails() async {
        let cached = Utils.getLocalYelpCacheForBusiness(id: restaurantId)
        if cached.name != "" {
            currentRestaurant = cached
            return
        }

        do {
            currentRestaurant = try await BusinessFetcher.getBusiness(id: restaurantId)
            apiError = false
        } catch {
            print("Request failed with error: \(error)")
            apiError = true
        }
    }

    private func addToList(list: SavedList, id: String, name: String) {
        if list.restaurantsArray.contains(where: { $0.name == name }) {
            isShowingDuplicateAlert.toggle()
            return
        }

        let savedRestaurant = SavedRestaurant(context: moc)
        savedRestaurant.addToLists(list)
        savedRestaurant.id = id
        savedRestaurant.name = name

        do {
            try moc.save()
            isShowingAddedToListAlert.toggle()
        } catch {
            isShowingAddedToListErrorAlert.toggle()
        }
    }
}
