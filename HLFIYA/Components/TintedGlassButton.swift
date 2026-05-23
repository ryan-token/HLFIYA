//
//  TintedGlassButton.swift
//  HLFIYA
//
//  Created by Ryan Token on 9/24/25.
//

import SwiftUI

struct TintedGlassButton<Label: View>: View {
    enum GlassTintStyle { case standard, prominent }

    let action: () -> Void
    @ViewBuilder let label: Label
    let tintColor: Color
    let style: GlassTintStyle

    var body: some View {
        Group {
            switch style {
            case .standard:
                Button(action: action) { label }
                    .buttonStyle(.glass)
            case .prominent:
                Button(action: action) { label }
                    .buttonStyle(.glassProminent)
            }
        }
        .tint(tintColor)
    }
}

#Preview {
    TintedGlassButton(
        action: { print("Button tapped!") },
        label: { Text("My Button") },
        tintColor: .fuchsia,
        style: .prominent
    )
}
