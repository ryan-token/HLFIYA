//
//  SettingsSupportSection.swift
//  HLFIYA
//

import StoreKit
import SwiftUI

/// Rating the app, removing ads, and restoring purchases.
struct SettingsSupportSection: View {
    /// Set to a message when a purchase or restore fails.
    @Binding var errorMessage: String?

    @Environment(StoreManager.self) private var storeManager
    @Environment(\.openURL) private var openURL

    private static let reviewURL = URL(
        string: "https://apps.apple.com/app/id1621818779?action=write-review"
    )

    var body: some View {
        Section("Support") {
            Button(action: openReviewPage) {
                SettingsRow(
                    iconName: "heart.square.fill",
                    iconColor: .fuchsia,
                    title: "Rate on the App Store",
                    showsExternalLinkIndicator: true
                )
            }

            if !storeManager.hasRemovedAds, let product = storeManager.removeAdsProduct {
                AsyncButton(action: purchaseRemoveAds) {
                    SettingsRow(
                        iconName: "star.square.fill",
                        iconColor: .green,
                        title: "Remove Ads for \(product.displayPrice)"
                    )
                }
            }

            AsyncButton(action: restorePurchases) {
                SettingsRow(iconName: "arrow.clockwise.square.fill", iconColor: .indigo, title: "Restore Purchases")
            }
        }
    }

    private func openReviewPage() {
        if let url = Self.reviewURL {
            openURL(url)
        }
    }

    private func purchaseRemoveAds() async {
        errorMessage = await storeManager.purchaseRemoveAds()
    }

    private func restorePurchases() async {
        do {
            try await storeManager.restorePurchases()
        } catch {
            errorMessage = "Restoring purchases failed. Please try again."
        }
    }
}
