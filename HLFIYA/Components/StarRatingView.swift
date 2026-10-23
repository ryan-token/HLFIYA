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
                Image(systemName: Double(star) - displayedRating == 0.5 ? "star.leadinghalf.filled" : "star.fill")
                    .foregroundStyle(Double(star) > displayedRating + 0.5 ? .gray : .yellow)
            }

            if let reviewCount {
                Text("(\(reviewCount))")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    /// Yelp ratings can have any decimal, but the stars only show halves.
    private var displayedRating: Double {
        (rating * 2).rounded() / 2
    }

    private var accessibilityLabel: Text {
        let stars = Text("Yelp rating: \(rating, format: .number.precision(.fractionLength(1))) stars")
        guard let reviewCount else { return stars }
        return Text("\(stars), ^[\(reviewCount) review](inflect: true)")
    }
}

#Preview {
    StarRatingView(rating: 3.5, label: "Rating:", reviewCount: 120)
}
