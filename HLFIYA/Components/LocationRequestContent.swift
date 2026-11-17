//
//  LocationRequestContent.swift
//  HLFIYA
//

import SwiftUI

/// The wordmark and location buttons of the intro, revealed step by step.
struct LocationRequestContent: View {
    let introStep: IntroStep

    var body: some View {
        VStack {
            IntroWordmark(introStep: introStep)
            IntroLocationButtons(introStep: introStep)
        }
        // The status bar can sit at the side on iPhone Duo, leaving no top inset.
        .padding()
    }
}

#Preview {
    LocationRequestContent(introStep: .buttons)
        .foregroundStyle(.fuchsia)
        .environment(LocationViewModel())
}
