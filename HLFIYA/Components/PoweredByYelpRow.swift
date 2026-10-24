//
//  PoweredByYelpRow.swift
//  HLFIYA
//

import SwiftUI

/// The Yelp attribution required wherever Yelp data is shown.
struct PoweredByYelpRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .body) private var logoWidth = 75.0

    var body: some View {
        LabeledContent("Powered by") {
            Image(colorScheme == .dark ? .yelpLogoDarkBg : .yelpLogo)
                .resizable()
                .scaledToFit()
                .frame(width: logoWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Powered by Yelp")
        .listRowBackground(Color.clear)
    }
}

#Preview {
    List {
        PoweredByYelpRow()
    }
}
