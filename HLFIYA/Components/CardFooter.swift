//
//  CardFooter.swift
//  HLFIYA
//

import SwiftUI

/// The name, rating, price, and category shown at the bottom of a card.
struct CardFooter: View {
    let name: String
    let rating: Double
    let price: String
    let category: String
    let canUndo: Bool
    let undo: UndoSwipeAction

    @ScaledMetric(relativeTo: .body) private var yelpLogoWidth = 30.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(name)
                .font(.largeTitle)
                .bold()
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            HStack {
                StarRatingView(rating: rating)
                Spacer()
                Button("Undo", systemImage: "arrow.uturn.backward.circle.fill") {
                    undo()
                }
                .labelStyle(.iconOnly)
                .font(.largeTitle)
                .foregroundStyle(canUndo ? .yellow : .gray)
                .disabled(!canUndo)
            }

            DollarView(price: price)

            HStack {
                Text(category)
                Spacer()
                Image(.yelpBurst)
                    .resizable()
                    .scaledToFit()
                    .frame(width: yelpLogoWidth)
                    .accessibilityLabel("Yelp Logo")
            }
        }
        .foregroundStyle(.white)
        .padding()
    }
}
