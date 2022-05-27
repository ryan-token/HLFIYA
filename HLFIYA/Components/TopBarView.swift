//
//  TopBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI
import MapKit

struct TopBarView: View {
    @State private var isShowingSettingsView = false
    @State private var isShowingMapView = false
    
    @Binding var customLatitude: CLLocationDegrees
    @Binding var customLongitude: CLLocationDegrees
    @Binding var customRadius: Double
    
    var body: some View {
        HStack {
            Button(action: {
                isShowingMapView.toggle()
            }) {
                Image(systemName: "location.circle.fill")
                    .font(Font.system(size: 45, design: .rounded))
            }
            
            Spacer()
            
            Button(action: {
                isShowingSettingsView.toggle()
            }) {
                Image(systemName: "gear.circle.fill")
                    .font(Font.system(size: 45, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            .popover(isPresented: $isShowingSettingsView) {
                SettingsView()
            }
            
            .popover(isPresented: $isShowingMapView) {
                MapView(customLatitude: $customLatitude, customLongitude: $customLongitude, customRadius: $customRadius)
            }
        }
        .padding(.horizontal)
    }
}

//struct TopBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopBarView()
//    }
//}
