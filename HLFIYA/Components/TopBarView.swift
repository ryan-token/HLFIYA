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
    
    var body: some View {
        HStack {
            
            Button(action: {
                isShowingSettingsView.toggle()
            }) {
                Image(systemName: "gear.circle.fill")
                    .font(Font.system(size: 45, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                print("does nothing")
            }) {
                Image(systemName: "person.circle.fill")
                    .font(Font.system(size: 45, design: .rounded))
            }
            
            .popover(isPresented: $isShowingSettingsView) {
                SettingsView()
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
