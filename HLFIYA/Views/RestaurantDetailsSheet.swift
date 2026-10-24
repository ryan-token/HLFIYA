//
//  RestaurantDetailsSheet.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/27/22.
//

import StoreKit
import SwiftUI

/// The details sheet shown after swiping right on a card.
struct RestaurantDetailsSheet: View {
    let restaurantID: String
    let restaurantName: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    /// Ask for an App Store review at most once a week.
    private static let reviewRequestInterval: TimeInterval = 7 * 24 * 60 * 60

    var body: some View {
        NavigationStack {
            RestaurantDetailsList(restaurantID: restaurantID, restaurantName: restaurantName)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) {
                            dismiss()
                        }
                    }
                }
        }
        .tint(.fuchsia)
        .onDisappear(perform: requestReviewIfDue)
    }

    private func requestReviewIfDue() {
        #if DEBUG
        guard !ScreenshotMode.isEnabled else { return }
        #endif
        let lastRequest = Utils.getLastReviewRequestDate() ?? .distantPast
        guard lastRequest < Date.now.addingTimeInterval(-Self.reviewRequestInterval) else { return }

        requestReview()
        Utils.writeReviewDateToDocumentsDir(date: .now)
    }
}

#Preview {
    RestaurantDetailsSheet(restaurantID: "Xg-FyjVKAN70LO4u4Z1ozg", restaurantName: "Hog Island Oyster")
        .environment(LocationViewModel())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
