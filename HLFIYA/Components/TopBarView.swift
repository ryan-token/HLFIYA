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
            TintedGlassButton(
                action: {
                    isShowingSettingsView.toggle()
                },
                label: {
                    Image(systemName: "gear")
                        .font(Font.system(size: 30, weight: .semibold, design: .rounded))
                },
                tintColor: Color(UIColor(named: "fuchsia")!),
                style: .standard
            )
            .accessibilityLabel("Settings")
            .popover(isPresented: $isShowingSettingsView) {
                SettingsView()
            }
            
            Spacer()

            TintedGlassButton(
                action: {
                    isShowingListsView.toggle()
                },
                label: {
                    Image(systemName: "list.bullet")
                        .font(Font.system(size: 30, weight: .semibold, design: .rounded))
                },
                tintColor: Color(UIColor(named: "fuchsia")!),
                style: .standard
            )
            .accessibilityLabel("Lists")
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
