//
//  StarRatingView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/25/22.
//

import SwiftUI

struct StarRatingView: View {
    var rating: Double
    var label: String?
    var reviewCount: Int?
    var maximumRating = 5
    var offColor = Color.gray
    var onColor = Color.yellow

    var body: some View {
        HStack {
            if let label {
                Text(label)
                    .foregroundStyle(.gray)
            }

            ForEach(1..<maximumRating + 1, id: \.self) { number in
                starImage(for: number)
                    .foregroundStyle(Double(number) > rating + 0.5 ? offColor : onColor)
            }

            if let reviewCount {
                Text("(\(reviewCount))")
                    .foregroundStyle(.gray)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Yelp rating: \(rating, format: .number.precision(.fractionLength(1))) stars")
    }

    private func starImage(for number: Int) -> Image {
        let difference = Double(number) - rating
        return difference == 0.5 ? Image(systemName: "star.leadinghalf.filled") : Image(systemName: "star.fill")
    }
}

#Preview {
    StarRatingView(rating: -0.5, label: "Rating:")
}
