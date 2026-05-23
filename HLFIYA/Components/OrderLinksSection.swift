//
//  OrderLinksSection.swift
//  HLFIYA
//

import SwiftUI

struct OrderLinksSection: View {
    let restaurant: BusinessDetails
    @Environment(LocationViewModel.self) private var locationViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            ExternalLinkButton(title: "Search DoorDash") {
                openAppOrSafari(for: .doorDash)
            }

            ExternalLinkButton(title: "Search Uber Eats") {
                openAppOrSafari(for: .uberEats)
            }

            ExternalLinkButton(title: "Search OpenTable") {
                openAppOrSafari(for: .openTable)
            }

            ExternalLinkRow {
                Link("See More on Yelp", destination: URL(string: restaurant.url ?? "#") ?? URL(string: "https://yelp.com")!)
            }
        } header: {
            Text("Order").foregroundStyle(.gray)
        }
        .foregroundStyle(.fuchsia)
    }

    private enum DeliveryApp { case doorDash, uberEats, openTable }

    private func openAppOrSafari(for app: DeliveryApp) {
        guard let name = restaurant.name,
              let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

        let urlScheme: String
        let safariUrl: String

        switch app {
        case .doorDash:
            let path = "search/store/\(encodedName)/?event_type=search"
            urlScheme = "doordash:///\(path)"
            safariUrl = "https://www.doordash.com/\(path)"

        case .uberEats:
            let path = "search?diningMode=DELIVERY&q=\(encodedName)&sc=SEARCH_SUGGESTION&vertical=ALL"
            urlScheme = "ubereats://\(path)"
            safariUrl = "https://www.ubereats.com/\(path)"

        case .openTable:
            let now = Date.now.formatted(.iso8601.year().month().day().dateTimeSeparator(.standard).time(includingFractionalSeconds: false))
            let latLong: String
            if let location = locationViewModel.location {
                latLong = "&latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)"
            } else {
                latLong = ""
            }
            let path = "s?dateTime=\(now)&covers=2\(latLong)&term=\(encodedName)&shouldUseLatLongSearch=true&sortBy=web_conversion&originalTerm=\(encodedName)&intentModifiedTerm=\(encodedName)&queryUnderstandingType=default"
            urlScheme = "opentable"
            safariUrl = "https://www.opentable.com/\(path)"
        }

        if app == .openTable {
            if let url = URL(string: safariUrl) { openURL(url) }
            return
        }

        guard let customSchemeURL = URL(string: urlScheme) else { return }
        openURL(customSchemeURL) { accepted in
            if !accepted, let webUrl = URL(string: safariUrl) {
                openURL(webUrl)
            }
        }
    }
}

private struct ExternalLinkButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        ExternalLinkRow {
            Button(title, action: action)
        }
    }
}

private struct ExternalLinkRow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            content
            Spacer()
            Image(systemName: "arrow.up.forward")
                .foregroundStyle(.tertiary)
                .font(.callout)
        }
    }
}
