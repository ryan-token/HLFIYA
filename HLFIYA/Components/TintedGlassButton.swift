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
    @ViewBuilder let label: () -> Label
    let tintColor: Color
    let style: GlassTintStyle

    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label, tintColor: Color, style: GlassTintStyle) {
        self.action = action
        self.label = label
        self.tintColor = tintColor
        self.style = style
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            if style == .standard {
                Button(action: action, label: label)
                    .buttonStyle(.glass)
                    .tint(tintColor)
            } else {
                Button(action: action, label: label)
                    .buttonStyle(.glassProminent)
                    .tint(tintColor)
            }
        } else {
            Button(action: action, label: label)
                .foregroundColor(tintColor)
        }
    }
}

#Preview {
    TintedGlassButton(
        action: {
            print("Button tapped!")
        },
        label: {
            Text("My Button")
        },
        tintColor: Color(UIColor(named: "fuchsia")!),
        style: .prominent
    )
}
