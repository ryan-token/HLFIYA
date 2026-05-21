//
//  AsyncButton.swift
//  HLFIYA
//
//  Created by Ryan Token on 2/22/22.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    @ViewBuilder var label: () -> Label

    @State private var isPerformingTask = false

    var body: some View {
        Button {
            isPerformingTask = true
            Task {
                await action()
                isPerformingTask = false
            }
        } label: {
            ZStack {
                // Hide the label by setting its opacity to zero so the button's
                // size doesn't change while the task is performed.
                label().opacity(isPerformingTask ? 0 : 1)

                if isPerformingTask {
                    ProgressView()
                }
            }
        }
        .disabled(isPerformingTask)
    }
}
