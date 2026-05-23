//
//  GlassButton.swift
//  HLFIYA
//
//  Created by Ryan Token on 9/25/25.
//

import SwiftUI

struct GlassButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: Label

    var body: some View {
        Button(action: action) { label }
            .buttonStyle(.glass)
    }
}

#Preview {
    GlassButton(action: {}) {
        Text("Create List")
    }
    .padding()
}
