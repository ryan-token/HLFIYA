//
//  RestaurantPhotosSection.swift
//  HLFIYA
//

import SwiftUI

struct RestaurantPhotosSection: View {
    let photos: [String]
    @Binding var selectedTab: Int

    var body: some View {
        Section("Photos") {
            ImageSliderView(selectedTab: $selectedTab, imageUrls: photos.isEmpty ? [""] : photos)
                .frame(height: 300)
                .listRowInsets(EdgeInsets())
        }
    }
}
