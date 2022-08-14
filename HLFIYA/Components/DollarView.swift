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
    var dollarImage = Image(systemName: "dollarsign.circle")
    var offColor = Color.gray
    var onColor = Color.green
    
    var body: some View {
        HStack {
            if label.isEmpty == false {
                Text(label)
                    .foregroundColor(.gray)
                    .font(Font.system(.body, design: .rounded))
                
                Spacer()
                    .frame(width: 20)
            }
            
            ForEach(1..<maximumPrice + 1, id: \.self) { possiblePrice in
                dollarImage
                    .foregroundColor(possiblePrice > countDollarSigns(from: price) ? offColor : onColor)
                
                Spacer()
                    .frame(width: 10.3)
            }
        }
        .accessibilityLabel("Price: \(price.count) dollar signs")
    }
    
    func countDollarSigns(from: String) -> Int {
        return from.count
    }
}

struct DollarView_Previews: PreviewProvider {
    static var previews: some View {
        DollarView(price: "$$", label: "Price:")
    }
}
