//
//  StarRatingView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/26/22.
//

import SwiftUI

/// A five-star Yelp rating, with an optional label and review count.
struct StarRatingView: View {
    let rating: Double
    var label: LocalizedStringResource?
    var reviewCount: Int?

    private static let maximumRating = 5

    var body: some View {
        HStack {
            if let label {
                Text(label)
                    .foregroundStyle(.secondary)
            }

            ForEach(1...Self.maximumRating, id: \.self) { star in
                Image(systemName: Double(star) - rating == 0.5 ? "star.leadinghalf.filled" : "star.fill")
                    .foregroundStyle(Double(star) > rating + 0.5 ? .gray : .yellow)
            }

            if let reviewCount {
                Text("(\(reviewCount))")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Yelp rating: \(rating, format: .number.precision(.fractionLength(1))) stars")
    }
}

#Preview {
    StarRatingView(rating: 3.5, label: "Rating:", reviewCount: 120)
}
