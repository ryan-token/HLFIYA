//
//  CardFooter.swift
//  HLFIYA
//

import SwiftUI

/// The name, rating, price, and category shown at the bottom of a card, at the size its
/// style asks for.
struct CardFooter: View {
    let summary: CardSummary
    let canUndo: Bool
    let undo: UndoSwipeAction
    var style = CardFooterStyle.regular

    @ScaledMetric(relativeTo: .body) private var yelpLogoWidth = 30.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(summary.name)
                .font(style.nameFont)
                .bold()
                .lineLimit(style.nameLineLimit)
                .minimumScaleFactor(0.75)
                .flexibleIdealWidth()

            HStack {
                if style.showsStarRow {
                    StarRatingView(rating: summary.rating)
                        .font(style.detailFont)
                } else {
                    CompactRatingView(rating: summary.rating)
                        .font(style.detailFont)
                }
                Spacer(minLength: 0)
                if !style.showsPriceAndCategory {
                    YelpBurst(width: yelpLogoWidth * style.yelpLogoScale)
                }
                Button("Undo", systemImage: "arrow.uturn.backward.circle.fill") {
                    undo()
                }
                .labelStyle(.iconOnly)
                .font(style.undoFont)
                .foregroundStyle(canUndo ? .yellow : .gray)
                .disabled(!canUndo)
            }

            if style.showsPriceAndCategory {
                DollarView(price: summary.price)
                    .font(style.detailFont)

                HStack {
                    Text(summary.category)
                        .font(style.detailFont)
                        .lineLimit(1)
                        .flexibleIdealWidth()
                    YelpBurst(width: yelpLogoWidth * style.yelpLogoScale)
                }
            }
        }
        .foregroundStyle(.white)
        .padding()
    }
}

#Preview {
    VStack {
        ForEach(CardFooterStyle.allCases, id: \.self) { style in
            CardFooter(
                summary: CardSummary(name: "Jake's Brew Bar", rating: 4.5, price: "$$", category: "Beer Gardens"),
                canUndo: true,
                undo: UndoSwipeAction(feed: RestaurantFeed()),
                style: style
            )
            .background(.black)
        }
    }
}
