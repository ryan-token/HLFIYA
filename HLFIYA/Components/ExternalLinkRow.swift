//
//  ExternalLinkRow.swift
//  HLFIYA
//

import SwiftUI

/// A row that opens a link in another app, falling back to the website.
struct ExternalLinkRow: View {
    let title: LocalizedStringResource
    let link: DeliveryLinks.Link

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button(action: open) {
            LabeledContent {
                Image(systemName: "arrow.up.forward")
                    .foregroundStyle(.tertiary)
                    .font(.callout)
            } label: {
                Text(title)
                    .foregroundStyle(.tint)
            }
        }
        .disabled(link.appURL == nil && link.webURL == nil)
    }

    private func open() {
        guard let appURL = link.appURL else {
            if let webURL = link.webURL { openURL(webURL) }
            return
        }

        openURL(appURL) { accepted in
            if !accepted, let webURL = link.webURL {
                openURL(webURL)
            }
        }
    }
}

#Preview {
    List {
        ExternalLinkRow(
            title: "See More on Yelp",
            link: DeliveryLinks.Link(appURL: nil, webURL: URL(string: "https://www.yelp.com"))
        )
    }
}
