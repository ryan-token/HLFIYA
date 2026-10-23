//
//  CheckmarkToggleStyle.swift
//  HLFIYA
//

import SwiftUI

/// Draws a toggle as a list row with a trailing checkmark, for multiple-selection lists.
///
/// Keeping it a `Toggle` preserves its selected state for VoiceOver.
struct CheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .opacity(configuration.isOn ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(configuration.isOn ? .isSelected : [])
    }
}

extension ToggleStyle where Self == CheckmarkToggleStyle {
    static var checkmark: CheckmarkToggleStyle { CheckmarkToggleStyle() }
}

#Preview {
    @Previewable @State var isOn = true

    List {
        Toggle("Pizza", isOn: $isOn)
            .toggleStyle(.checkmark)
    }
}
