//
//  RestaurantDetailsModel.swift
//  HLFIYA
//

import CoreData
import Observation
import os

/// Loads one restaurant's details and adds it to saved lists.
@Observable
final class RestaurantDetailsModel {
    /// The outcome of adding the restaurant to a list, shown as an alert.
    enum ListAlert: Equatable {
        case added(listName: String)
        case alreadyInList(listName: String)
        case failed(listName: String)
    }

    private(set) var details: BusinessDetails?
    private(set) var loadFailed = false
    var listAlert: ListAlert?
    var isShowingCreateListSheet = false

    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "RestaurantDetails")

    func load(restaurantID: String) async {
        do {
            details = try await BusinessFetcher.getBusiness(id: restaurantID)
            loadFailed = false
        } catch is CancellationError {
            // The screen closed before the request finished.
        } catch {
            let reason = error.localizedDescription
            Self.logger.error("Failed to load \(restaurantID, privacy: .public): \(reason, privacy: .public)")
            loadFailed = true
        }
    }

    /// Saves the restaurant to a list unless a restaurant with the same name is already there.
    func add(restaurantID: String, name: String, to list: SavedList, in context: NSManagedObjectContext) {
        let listName = list.wrappedName
        guard !list.restaurantsArray.contains(where: { $0.name == name }) else {
            listAlert = .alreadyInList(listName: listName)
            return
        }

        let savedRestaurant = SavedRestaurant(context: context)
        savedRestaurant.id = restaurantID
        savedRestaurant.name = name
        savedRestaurant.addToLists(list)

        do {
            try context.save()
            listAlert = .added(listName: listName)
        } catch {
            Self.logger.error("Failed to save restaurant to list: \(error.localizedDescription, privacy: .public)")
            context.rollback()
            listAlert = .failed(listName: listName)
        }
    }
}

extension RestaurantDetailsModel.ListAlert {
    func title(restaurantName: String) -> String {
        switch self {
        case .added(let listName):
            "Added \(restaurantName) to your \(listName) list"
        case .alreadyInList(let listName):
            "\(restaurantName) is already in your \(listName) list!"
        case .failed(let listName):
            "Error adding \(restaurantName) to your \(listName) list"
        }
    }
}
