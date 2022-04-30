//
//  ImageSlider.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import SwiftUI

struct ImageSliderView: View {
    let imageUrls: [String]
    
    var body: some View {
        TabView {
            ForEach(imageUrls, id: \.self) { url in
                AsyncImageHack(url: url, isScaledToFill: true)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView(imageUrls: [
            "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg",
            "https://s3-media4.fl.yelpcdn.com/bphoto/ahmWdH7P0UIc4lM1c8zhcQ/o.jpg",
            "https://s3-media2.fl.yelpcdn.com/bphoto/BlG7QLi2mseijvxFnAb5yg/o.jpg"
        ])
            .previewLayout(.fixed(width: 400, height: 300))
    }
}
