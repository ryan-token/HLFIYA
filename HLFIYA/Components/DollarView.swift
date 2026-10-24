//
//  DollarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/3/22.
//

import SwiftUI

/// A Yelp price level drawn as four dollar-sign symbols, with an optional label.
struct DollarView: View {
    /// The Yelp price string, such as "$$".
    let price: String
    var label: LocalizedStringResource?

    private static let maximumPrice = 4

    var body: some View {
        HStack {
            if let label {
                Text(label)
                    .foregroundStyle(.secondary)
                    .padding(.trailing)
            }

            ForEach(1...Self.maximumPrice, id: \.self) { level in
                Image(systemName: "dollarsign.circle")
                    .foregroundStyle(level > price.count ? .gray : .green)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Price: \(price.count) dollar signs")
    }
}

#Preview {
    DollarView(price: "$$", label: "Price:")
}
