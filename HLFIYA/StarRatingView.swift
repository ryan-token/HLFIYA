//
//  StarRatingView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/25/22.
//

import SwiftUI

struct StarRatingView: View {
    var rating: Double
    var maximumRating = 5
    var halfStarImage = Image(systemName: "star.leadinghalf.filled")
    var fullStarImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var body: some View {
        HStack {
            Text("Rating:")
                .font(.headline)
            ForEach(1..<maximumRating + 1, id: \.self) { number in
                starImage(for: number)
                    .foregroundColor(Double(number) > rating + 0.5 ? offColor : onColor)
            }
        }
    }
    
    func starImage(for number: Int) -> Image {
        let numberAsDouble = Double(number)
        let difference = numberAsDouble - rating
        print(difference)
        
        if difference == 0.5 {
            return halfStarImage
        } else {
            return fullStarImage
        }
    }
}

struct StarRatingView_Previews: PreviewProvider {
    static var previews: some View {
        StarRatingView(rating: -0.5)
    }
}
