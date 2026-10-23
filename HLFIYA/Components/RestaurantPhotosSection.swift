//
//  RestaurantPhotosSection.swift
//  HLFIYA
//

import SwiftUI

/// A section with a paging carousel of the restaurant's photos.
struct RestaurantPhotosSection: View {
    let photos: [String]

    @State private var selection = 0

    var body: some View {
        Section("Photos") {
            ImageSliderView(selection: $selection, imageURLs: photos.isEmpty ? [""] : photos)
                .aspectRatio(3 / 2, contentMode: .fit)
                .listRowInsets(EdgeInsets())
        }
    }
}

#Preview {
    List {
        RestaurantPhotosSection(photos: ["https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg"])
    }
}
