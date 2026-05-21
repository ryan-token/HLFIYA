//
//  DollarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/25/22.
//

import SwiftUI

struct DollarView: View {
    var price: String
    var label: String
    var maximumPrice = 4
    var offColor = Color.gray
    var onColor = Color.green

    var body: some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    .foregroundStyle(.gray)

                Spacer()
                    .frame(width: 20)
            }

            ForEach(1..<maximumPrice + 1, id: \.self) { possiblePrice in
                Image(systemName: "dollarsign.circle")
                    .foregroundStyle(possiblePrice > price.count ? offColor : onColor)

                Spacer()
                    .frame(width: 10.3)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Price: \(price.count) dollar signs")
    }
}

#Preview {
    DollarView(price: "$$", label: "Price:")
}
