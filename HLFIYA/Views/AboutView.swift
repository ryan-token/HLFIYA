//
//  AboutView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import SwiftUI

/// About the app and its developer, with links to their other apps.
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private static let reviewURL = URL(
        string: "https://apps.apple.com/us/app/hot-local-food/id1621818779?action=write-review"
    )

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    AboutHeader()
                        .listRowBackground(Color.clear)
                }

                Section {
                    Text(
                        """
                        Hot Local Food was built by two friends who just needed a better way \
                        to find some good food nearby.
                        """
                    )

                    Text("Thank you for using the app. Please leave a review if you find it valuable.")

                    Button("Rate on the App Store", systemImage: "heart.square.fill", action: openReviewPage)
                        .font(.headline)
                }

                Section("Try my other apps") {
                    OtherAppRow(
                        image: .catchUp1024,
                        title: "CatchUp: Keep in Touch",
                        subtitle: "Personal relationship manager",
                        url: URL(string: "itms-apps://apps.apple.com/us/app/catchup-keep-in-touch/id1358023550")
                    )

                    OtherAppRow(
                        image: .outrank1024,
                        title: "Outrank: CFB Stat Rankings",
                        subtitle: "College football team stats",
                        url: URL(string: "itms-apps://apps.apple.com/us/app/outrank/id1588983785")
                    )
                }
            }
            .navigationTitle("About")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .tint(.fuchsia)
    }

    private func openReviewPage() {
        if let url = Self.reviewURL {
            openURL(url)
        }
    }
}

#Preview {
    AboutView()
}
