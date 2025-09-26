//
//  GlassButton.swift
//  HLFIYA
//
//  Created by Ryan Token on 9/25/25.
//

import SwiftUI

struct GlassButton<Label: View>: View {
	let action: () -> Void
	@ViewBuilder let label: () -> Label

	init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
		self.action = action
		self.label = label
	}

	var body: some View {
		if #available(iOS 26, macOS 26, *) {
			Button(action: action, label: label)
				.buttonStyle(.glass)
		} else {
			Button(action: action, label: label)
				.buttonStyle(.bordered)
				.background(.ultraThinMaterial)
				.clipShape(Capsule())
				.padding(.bottom)
		}
	}
}

#Preview {
	GlassButton(action: {}) {
		Text("Create List")
	}
	.padding()
}
