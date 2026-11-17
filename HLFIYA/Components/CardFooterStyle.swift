//
//  CardFooterStyle.swift
//  HLFIYA
//

import SwiftUI

/// How much room a card's footer takes, from the full-size version down to the essentials
/// for a very small card. Every style keeps the name, rating, Yelp logo, and Undo button.
enum CardFooterStyle: CaseIterable {
    /// A large name, then the rating, price, and category on their own lines.
    case regular

    /// The same details at smaller text sizes.
    case compact

    /// Just the name on one line and the rating as a number.
    case minimal

    var nameFont: Font {
        switch self {
        case .regular: .largeTitle
        case .compact: .title2
        case .minimal: .headline
        }
    }

    var nameLineLimit: Int {
        self == .minimal ? 1 : 2
    }

    /// The text size of the rating, price, and category.
    var detailFont: Font {
        switch self {
        case .regular: .body
        case .compact: .footnote
        case .minimal: .caption
        }
    }

    var undoFont: Font {
        switch self {
        case .regular: .largeTitle
        case .compact: .title
        case .minimal: .title2
        }
    }

    /// Whether the rating is drawn as five stars, rather than one star and a number.
    var showsStarRow: Bool {
        self != .minimal
    }

    var showsPriceAndCategory: Bool {
        self != .minimal
    }

    /// The Yelp logo's size relative to the regular footer's.
    var yelpLogoScale: Double {
        switch self {
        case .regular: 1
        case .compact: 0.8
        case .minimal: 0.65
        }
    }
}
