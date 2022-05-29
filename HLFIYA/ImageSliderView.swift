//
//  ImageSlider.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import SwiftUI

struct ImageSliderView: View {
    var tabOptions = [Int]()
    let imageUrls: [String]
    
    @Binding private var selectedTab: Int
    
    init(selectedTab: Binding<Int>, imageUrls: [String]) {
        _selectedTab = selectedTab
        self.imageUrls = imageUrls
        for number in 1...imageUrls.count {
            tabOptions.append(number)
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(imageUrls, id: \.self) { url in
                let index = imageUrls.firstIndex(of: url)
                
                AsyncImageHack(url: url, isScaledToFill: true)
                    .tag(tabOptions[index ?? 0])
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .animation(.default, value: selectedTab)
        
        .onTapGesture {
            if selectedTab == imageUrls.count {
                selectedTab = 1
            } else {
                selectedTab += 1
            }
        }
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView(selectedTab: .constant(1), imageUrls: [
            "https://s3-media2.fl.yelpcdn.com/bphoto/4avfA7HWOW_Bl0J_8J60rg/o.jpg",
            "https://s3-media4.fl.yelpcdn.com/bphoto/ahmWdH7P0UIc4lM1c8zhcQ/o.jpg",
            "https://s3-media2.fl.yelpcdn.com/bphoto/BlG7QLi2mseijvxFnAb5yg/o.jpg"
        ])
            .previewLayout(.fixed(width: 400, height: 300))
    }
}
