//
//  TopBarView.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/18/22.
//

import SwiftUI

struct TopBarView: View {
    @State private var isShowingSettingsView = false
    @State private var isShowingListsView = false
    
    var body: some View {
        HStack {
            
            Button(action: {
                isShowingSettingsView.toggle()
            }) {
                Image(systemName: "gear")
                    .font(Font.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
            }
            .accessibilityLabel("Settings")
            
            Spacer()
            
            Button(action: {
                isShowingListsView.toggle()
            }) {
                Image(systemName: "list.bullet")
                    .font(Font.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(UIColor(named: "fuchsia")!))
            }
            .accessibilityLabel("Lists")
            
            .popover(isPresented: $isShowingSettingsView) {
                SettingsView()
            }
            
            .popover(isPresented: $isShowingListsView) {
                ListsView()
            }
        }
        .padding(.horizontal)
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView()
    }
}
