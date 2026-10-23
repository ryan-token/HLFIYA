//
//  SettingsGeneralSection.swift
//  HLFIYA
//

import SwiftUI

/// Location permissions, feature requests, About, and the legal links.
struct SettingsGeneralSection: View {
    @Binding var isShowingAboutScreen: Bool

    @State private var isShowingLegalDialog = false
    @Environment(\.openURL) private var openURL

    private static let privacyPolicyURL = URL(string: "https://ryantoken.com/privacy-policy")
    private static let termsOfUseURL = URL(string: "https://ryantoken.com/terms-of-use")

    var body: some View {
        Section("General") {
            NavigationLink(value: SettingsDestination.locationPermissions) {
                SettingsRow(iconName: "location.square.fill", iconColor: .blue, title: "Location Permissions")
            }

            Button(action: sendFeatureRequestEmail) {
                SettingsRow(
                    iconName: "bolt.square.fill",
                    iconColor: .mint,
                    title: "Feature Request",
                    showsExternalLinkIndicator: true
                )
            }
            .accessibilityHint("Opens an email to send a feature request.")

            Button {
                isShowingAboutScreen = true
            } label: {
                SettingsRow(iconName: "person.crop.square.fill", iconColor: .fuchsia, title: "About")
            }

            Button {
                isShowingLegalDialog = true
            } label: {
                SettingsRow(iconName: "lock.square.fill", iconColor: .gray, title: "Terms & Privacy Policy")
            }
            .confirmationDialog(
                "Terms of Use and Privacy Policy",
                isPresented: $isShowingLegalDialog,
                titleVisibility: .visible
            ) {
                Button("Terms of Use") { open(Self.termsOfUseURL) }
                Button("Privacy Policy") { open(Self.privacyPolicyURL) }
            }
        }
    }

    private func open(_ url: URL?) {
        if let url {
            openURL(url)
        }
    }

    private func sendFeatureRequestEmail() {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "hotlocalfood@gmail.com"
        components.queryItems = [URLQueryItem(name: "subject", value: "Feature Request - Hot Local Food")]
        open(components.url)
    }
}
