//
//  YelpBurst.swift
//  HLFIYA
//

import SwiftUI

/// The Yelp logo that credits Yelp for a card's details.
struct YelpBurst: View {
    let width: Double

    var body: some View {
        Image(.yelpBurst)
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .accessibilityLabel("Yelp Logo")
    }
}

#Preview {
    YelpBurst(width: 30)
}
