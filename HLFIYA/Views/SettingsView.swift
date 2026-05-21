//
//  SettingsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(StoreManager.self) private var storeManager

    @State private var isShowingAboutScreen = false
    @State private var isShowingPrivacyActionSheet = false
    @State private var isShowingError = false
    @State private var errorTitle = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Support") {
                    Button(action: requestReviewManually) {
                        SettingsRow(
                            iconName: "heart.square.fill",
                            iconColor: .fuchsia,
                            title: "Rate on the App Store",
                            showExternalLinkIndicator: true
                        )
                    }
                    .buttonStyle(.plain)

                    if storeManager.purchasedIds.isEmpty,
                       let removeAdsProduct = storeManager.products.first {
                        AsyncButton {
                            await purchaseRemoveAds(product: removeAdsProduct)
                        } label: {
                            SettingsRow(
                                iconName: "star.square.fill",
                                iconColor: .green,
                                title: "Remove Ads for \(removeAdsProduct.displayPrice)"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("General") {
                    NavigationLink {
                        LocationRequestView()
                    } label: {
                        SettingsRow(iconName: "location.square.fill", iconColor: .blue, title: "Location Permissions")
                    }
                    .accessibilityLabel("Open Location Permissions Screen")

                    Button(action: sendFeatureRequestEmail) {
                        SettingsRow(
                            iconName: "bolt.square.fill",
                            iconColor: .mint,
                            title: "Feature Request",
                            showExternalLinkIndicator: true
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Send an email with a feature request")

                    Button { isShowingAboutScreen.toggle() } label: {
                        SettingsRow(iconName: "person.crop.square.fill", iconColor: .fuchsia, title: "About")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("About Hot Local Food In Your Area")

                    Button { isShowingPrivacyActionSheet.toggle() } label: {
                        SettingsRow(iconName: "lock.square.fill", iconColor: .gray, title: "Terms & Privacy Policy")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Terms of Use and Privacy Policy")
                    .confirmationDialog(
                        "Terms of Use and Privacy Policy",
                        isPresented: $isShowingPrivacyActionSheet,
                        titleVisibility: .visible
                    ) {
                        Button("Terms of Use", action: openTermsOfUseLink)
                        Button("Privacy Policy", action: openPrivacyPolicyLink)
                    }
                }

                Section("Data") {
                    NavigationLink {
                        SwipesStatsView()
                    } label: {
                        SettingsRow(iconName: "arrow.left.arrow.right.square.fill", iconColor: .orange, title: "Swipes")
                    }

                    NavigationLink {
                        DeleteDataView()
                    } label: {
                        SettingsRow(iconName: "trash.square.fill", iconColor: .pink, title: "Delete Data")
                    }
                }

                if !storeManager.purchasedIds.isEmpty {
                    Text("You paid to remove ads. Thank you!")
                        .foregroundStyle(.gray)
                        .listRowBackground(Color.clear)
                }
            }
            .sheet(isPresented: $isShowingAboutScreen) {
                AboutView()
            }
            .alert(errorTitle, isPresented: $isShowingError) {}
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Restore Purchases", action: restorePurchases)
                        .font(.headline)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", action: dismiss.callAsFunction)
                        .font(.headline)
                }
            }
        }
        .tint(.fuchsia)
    }

    private func requestReviewManually() {
        guard let url = URL(string: "https://apps.apple.com/us/app/hot-local-food/id1621818779?action=write-review") else { return }
        openURL(url)
    }

    private func sendFeatureRequestEmail() {
        let email = "hotlocalfood@gmail.com"
        let subject = "Feature Request - Hot Local Food"

        guard let encoded = "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else { return }
        openURL(url)
    }

    private func openPrivacyPolicyLink() {
        if let url = URL(string: "https://ryantoken.com/privacy-policy") {
            openURL(url)
        }
    }

    private func openTermsOfUseLink() {
        if let url = URL(string: "https://ryantoken.com/terms-of-use") {
            openURL(url)
        }
    }

    private func purchaseRemoveAds(product: Product) async {
        do {
            _ = try await storeManager.purchase(product)
        } catch StoreError.failedVerification {
            HapticGenerator.playErrorHaptic()
            errorTitle = "Your purchase could not be verified by the App Store"
            isShowingError = true
        } catch {
            HapticGenerator.playErrorHaptic()
            print("Failed purchase for \(product.id): \(error)")
        }
    }

    private func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

private struct SettingsRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    var showExternalLinkIndicator: Bool = false

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title)
                .foregroundStyle(iconColor)
            Text(title)
                .foregroundStyle(.primary)
            if showExternalLinkIndicator {
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .foregroundStyle(.tertiary)
                    .font(.callout)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(StoreManager())
}
