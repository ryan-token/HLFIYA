//
//  RestaurantDetailsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import SwiftUI
import StoreKit

struct RestaurantDetailsView: View {
    var restaurant: Business

    @State private var currentRestaurant = BusinessDetails()
    @State private var apiError = false
    @State private var selectedTab = 1
    @State private var listTappedName = ""
    @State private var isShowingAddedToListAlert = false
    @State private var isShowingAddedToListErrorAlert = false
    @State private var isShowingDuplicateAlert = false
    @State private var isShowingCreateListSheet = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.requestReview) private var requestReview

    @FetchRequest(fetchRequest: SavedList.allListsFetchRequest)
    private var savedLists: FetchedResults<SavedList>

    var body: some View {
        NavigationStack {
            List {
                if apiError {
                    Text("😕 Error loading business details")
                        .foregroundStyle(.gray)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                RestaurantSummarySection(restaurant: currentRestaurant)

                RestaurantPhotosSection(
                    photos: currentRestaurant.photos ?? [],
                    selectedTab: $selectedTab
                )

                AddToListSection(
                    savedLists: savedLists,
                    onAddToList: { list in
                        listTappedName = list.wrappedName
                        addToList(list: list, id: restaurant.id ?? "", name: restaurant.name ?? "")
                    },
                    onCreateList: { isShowingCreateListSheet.toggle() }
                )

                OrderLinksSection(restaurant: currentRestaurant)

                RestaurantInfoSection(restaurant: currentRestaurant)

                PoweredByYelpRow()
            }
            .navigationTitle(currentRestaurant.name ?? "")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", action: dismiss.callAsFunction)
                        .font(.headline)
                }
            }
        }
        .tint(.fuchsia)
        .task {
            await loadBusinessDetails()
        }
        .onDisappear { maybeRequestReview() }
        .alert("Added \(restaurant.name ?? "") to your \(listTappedName) list", isPresented: $isShowingAddedToListAlert) {}
        .alert("Error adding \(restaurant.name ?? "") to your \(listTappedName) list", isPresented: $isShowingAddedToListErrorAlert) {}
        .alert("\(restaurant.name ?? "") is already in your \(listTappedName) list!", isPresented: $isShowingDuplicateAlert) {}
        .popover(isPresented: $isShowingCreateListSheet) {
            CreateListSheet()
        }
    }

    private func loadBusinessDetails() async {
        let cached = Utils.getLocalYelpCacheForBusiness(id: restaurant.id ?? "")
        if cached.name != "" {
            currentRestaurant = cached
            return
        }

        do {
            currentRestaurant = try await BusinessFetcher.getBusiness(id: restaurant.id ?? "")
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

    private func maybeRequestReview() {
        let lastReviewDateString = Utils.getLastReviewRequestFromDocumentsDir()
        let sevenDaysAgo = Date.now.addingTimeInterval(-604800)
        let lastReviewDate = (try? Date(lastReviewDateString, strategy: .dateTime)) ?? .distantPast

        if lastReviewDateString == "Unknown" || lastReviewDate < sevenDaysAgo {
            requestReview()
            Utils.writeReviewDateToDocumentsDir(date: .now)
        }
    }
}

#Preview {
    RestaurantDetailsView(restaurant: Business.data[1])
        .environment(LocationViewModel())
}
