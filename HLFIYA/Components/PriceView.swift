//
//  PriceView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/25/22.
//

import SwiftUI

struct PriceView: View {
    var price: String
    var maximumPrice = 5
    var dollarImage = Image(systemName: "dollarsign.circle")
    var offColor = Color.gray
    var onColor = Color.green
    
    var body: some View {
        HStack {
            Text("Price:")
                .foregroundColor(.gray)
            ForEach(1..<maximumPrice + 1, id: \.self) { possiblePrice in
                dollarImage
                    .foregroundColor(possiblePrice > countDollarSigns(from: price) ? offColor : onColor)
            }
        }
    }
    
    func countDollarSigns(from: String) -> Int {
        return from.count
    }
}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(price: "$$")
    }
}
