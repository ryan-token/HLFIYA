//
//  MultiPicker.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/5/22.
//

import SwiftUI

struct MultiPicker: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
