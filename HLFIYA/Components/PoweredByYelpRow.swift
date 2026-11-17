//
//  PoweredByYelpRow.swift
//  HLFIYA
//

import SwiftUI

/// The Yelp attribution required wherever Yelp data is shown.
struct PoweredByYelpRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var logoWidth = 75.0

    var body: some View {
        // Side by side, so it reads as one phrase: "Powered by [Yelp]". At
        // accessibility sizes the logo goes under the text, rather than splitting the words.
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())

        layout {
            Text("Powered by")
            Image(colorScheme == .dark ? .yelpLogoDarkBg : .yelpLogo)
                .resizable()
                .scaledToFit()
                .frame(width: logoWidth)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
