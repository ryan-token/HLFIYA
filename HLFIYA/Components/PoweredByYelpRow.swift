//
//  PoweredByYelpRow.swift
//  HLFIYA
//

import SwiftUI

struct PoweredByYelpRow: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            Text("Powered by:")

            Image(colorScheme == .light ? "yelp_logo" : "yelp_logo_dark_bg")
                .resizable()
                .scaledToFit()
                .frame(width: 75)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Powered by Yelp")
        .listRowBackground(Color.clear)
    }
}
