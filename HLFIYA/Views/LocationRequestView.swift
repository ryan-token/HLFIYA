//
//  LocationRequestView.swift
//  HLFIYA
//
//  Created by Ryan Token on 7/30/22.
//

import SwiftUI

/// The first-launch introduction that asks for location access. Also reachable from Settings.
///
/// The content is sized to the visible height so it always fits, and sits in a
/// scroll view only for the familiar bounce.
struct LocationRequestView: View {
    @AppStorage("userHasOpenedAppBefore") private var userHasOpenedAppBefore = false
    @State private var introStep = IntroStep.blank

    var body: some View {
        ScrollView {
            LocationRequestContent(introStep: introStep)
                .containerRelativeFrame(.vertical)
        }
        .foregroundStyle(.fuchsia)
        .navigationTitle("Location Permissions")
        .toolbar(removing: .title)
        .task {
            await animateIntro()
        }
    }

    private func animateIntro() async {
        guard !userHasOpenedAppBefore else {
            introStep = .buttons
            return
        }

        let steps: [(step: IntroStep, delay: Duration)] = [
            (.getReady, .seconds(1)),
            (.hot, .seconds(2)),
            (.local, .seconds(1)),
            (.food, .seconds(1)),
            (.buttons, .seconds(2))
        ]

        for (step, delay) in steps {
            do {
                try await Task.sleep(for: delay)
            } catch {
                introStep = .buttons
                return
            }
            withAnimation(.smooth(duration: 0.6)) { introStep = step }
        }
    }
}

#Preview {
    LocationRequestView()
        .environment(LocationViewModel())
}
