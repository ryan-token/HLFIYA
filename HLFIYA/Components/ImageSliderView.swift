//
//  ImageSlider.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import SwiftUI

struct ImageSliderView: View {
    @Binding var selectedTab: Int
    let imageUrls: [String]

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(imageUrls.enumerated(), id: \.offset) { index, url in
                AsyncImageHack(url: url, isScaledToFill: true)
                    .tag(index + 1)
            }
        }
        .tabViewStyle(.page)
        .animation(.default, value: selectedTab)
        .onTapGesture {
            selectedTab = selectedTab == imageUrls.count ? 1 : selectedTab + 1
        }
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    ImageSliderView(
        selectedTab: .constant(1),
        imageUrls: [
            "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg",
            "https://s3-media4.fl.yelpcdn.com/bphoto/ahmWdH7P0UIc4lM1c8zhcQ/o.jpg",
            "https://s3-media2.fl.yelpcdn.com/bphoto/BlG7QLi2mseijvxFnAb5yg/o.jpg"
        ]
    )
    .frame(width: 400, height: 300)
}
