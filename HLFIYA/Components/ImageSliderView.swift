//
//  ImageSliderView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import SwiftUI

/// A paging carousel of remote photos.
struct ImageSliderView: View {
    @Binding var selection: Int
    let imageURLs: [String]

    var body: some View {
        TabView(selection: $selection) {
            // Identified by position, so tags always match the selection range.
            ForEach(imageURLs.enumerated(), id: \.offset) { index, url in
                RemoteImage(url: URL(string: url))
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .animation(.default, value: selection)
    }
}

#Preview {
    @Previewable @State var selection = 0

    ImageSliderView(
        selection: $selection,
        imageURLs: [
            "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg",
            "https://s3-media4.fl.yelpcdn.com/bphoto/ahmWdH7P0UIc4lM1c8zhcQ/o.jpg",
            "https://s3-media2.fl.yelpcdn.com/bphoto/BlG7QLi2mseijvxFnAb5yg/o.jpg"
        ]
    )
    .aspectRatio(4 / 3, contentMode: .fit)
}
