//
//  AboutHeader.swift
//  HLFIYA
//

import SwiftUI

/// The app icon, name, and tagline at the top of the About screen.
struct AboutHeader: View {
    @ScaledMetric(relativeTo: .title) private var appIconSize = 100.0

    var body: some View {
        VStack {
            Image(.HLF_1024)
                .resizable()
                .scaledToFit()
                .frame(width: appIconSize, height: appIconSize)
                .clipShape(.rect(cornerRadius: appIconSize / 5))
                .shadow(radius: 10)
                .accessibilityHidden(true)

            Text("Hot Local Food")
                .font(.title)
                .bold()
                .accessibilityAddTraits(.isHeader)

            Text("Made with 💜 by an independent developer")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Made with love by an independent developer")
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AboutHeader()
}
