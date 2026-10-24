//
//  AsyncButton.swift
//  HLFIYA
//
//  Created by Ryan Token on 2/22/22.
//

import SwiftUI

/// A button that runs an async action, showing a spinner and disabling itself until it finishes.
struct AsyncButton<Label: View>: View {
    let action: () async -> Void
    @ViewBuilder let label: Label

    @State private var isPerformingTask = false

    var body: some View {
        Button {
            isPerformingTask = true
            Task {
                await action()
                isPerformingTask = false
            }
        } label: {
            // Hide the label rather than removing it, so the button keeps its size.
            label
                .opacity(isPerformingTask ? 0 : 1)
                .overlay {
                    if isPerformingTask {
                        ProgressView()
                    }
                }
        }
        .disabled(isPerformingTask)
    }
}

extension AsyncButton where Label == SwiftUI.Label<Text, Image> {
    init(_ titleKey: LocalizedStringKey, systemImage: String, action: @escaping () async -> Void) {
        self.action = action
        self.label = SwiftUI.Label(titleKey, systemImage: systemImage)
    }
}

#Preview {
    AsyncButton("Refresh", systemImage: "arrow.clockwise") {
        try? await Task.sleep(for: .seconds(1))
    }
}
