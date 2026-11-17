//
//  CompactRatingView.swift
//  HLFIYA
//

import SwiftUI

/// A Yelp rating as one star and a number, for cards too small for five stars.
struct CompactRatingView: View {
    let rating: Double

    var body: some View {
        Label {
            Text(rating, format: .number.precision(.fractionLength(1)))
                .lineLimit(1)
                .fixedSize()
        } icon: {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
        }
        .labelStyle(.titleAndIcon)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Yelp rating: \(rating, format: .number.precision(.fractionLength(1))) stars")
    }
}

#Preview {
    CompactRatingView(rating: 4.5)
}
