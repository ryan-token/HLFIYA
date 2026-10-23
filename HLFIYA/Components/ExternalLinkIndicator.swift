//
//  ExternalLinkIndicator.swift
//  HLFIYA
//

import SwiftUI

/// The trailing arrow on rows that open another app or website.
struct ExternalLinkIndicator: View {
    var body: some View {
        Image(systemName: "arrow.up.forward")
            .foregroundStyle(.tertiary)
            .font(.callout)
            .accessibilityHidden(true)
    }
}

#Preview {
    ExternalLinkIndicator()
}
