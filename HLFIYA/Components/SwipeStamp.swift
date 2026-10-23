//
//  SwipeStamp.swift
//  HLFIYA
//

import SwiftUI

/// A tilted, bordered word stamped onto a card while it's being swiped.
struct SwipeStamp: View {
    let text: LocalizedStringResource
    let foreground: Color
    let background: Color
    let border: Color
    let angle: Double

    var body: some View {
        Text(text)
            .font(.largeTitle)
            .bold()
            // The hidden stamp still takes half the row, so narrow cards would wrap the word.
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(foreground)
            .padding(5)
            .background(background, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(border, lineWidth: 4)
            }
            .rotationEffect(.degrees(angle))
    }
}

#Preview {
    SwipeStamp(text: "HOT 🥵", foreground: .fuchsia, background: .white, border: .fuchsia, angle: -25)
}
