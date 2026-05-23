//
//  RestaurantSummarySection.swift
//  HLFIYA
//

import SwiftUI

struct RestaurantSummarySection: View {
    let restaurant: BusinessDetails

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 5) {
                StarRatingView(rating: restaurant.rating ?? 0.0, label: "Rating:", reviewCount: restaurant.review_count)
                DollarView(price: restaurant.price ?? "", label: "Price:")

                if (restaurant.categories?.count ?? 0) < 2 {
                    HStack {
                        Text("Category:")
                        ForEach(restaurant.categories ?? [], id: \.self) { category in
                            Text(category.title ?? "")
                                .accessibilityLabel("\(restaurant.name ?? "restaurant") is a \(category.title ?? "") place")
                        }
                    }
                    .foregroundStyle(.gray)
                } else {
                    VStack(alignment: .leading) {
                        Text("Categories:")

                        Spacer()
                            .frame(height: 5)

                        ForEach(restaurant.categories ?? [], id: \.self) { category in
                            Text("– \(category.title ?? "")")
                                .padding(.leading, 25)
                                .accessibilityLabel("\(restaurant.name ?? "restaurant") is a \(category.title ?? "") place")
                        }
                    }
                    .foregroundStyle(.gray)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Rating, price, and categories for \(restaurant.name ?? "restaurant")")
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}
