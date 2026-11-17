//
//  FeedArrangementTests.swift
//  HLFIYATests
//

import CoreGraphics
@testable import HLFIYA
import SwiftUI
import Testing

struct FeedArrangementTests {
    private let arrangement = FeedArrangement(cardAspectRatio: 3.0 / 4, verticalSpacing: 8, horizontalSpacing: 8)

    /// A part that fills whatever width it's offered at a fixed height.
    private func fixedHeight(_ height: Double) -> (ProposedViewSize) -> CGSize {
        { proposal in CGSize(width: proposal.width ?? 0, height: height) }
    }

    @Test func tallWindowStacks() {
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 800)

        let frames = arrangement.frames(in: bounds, summarySize: fixedHeight(80), buttonsSize: fixedHeight(90))
        let stacked = arrangement.stackedFrames(in: bounds, summarySize: fixedHeight(80), buttonsSize: fixedHeight(90))

        #expect(frames == stacked)
        #expect(frames.summary.minY == 0)
        #expect(frames.buttons.maxY == 800)
        // 800 tall, less the summary, the buttons, and two gaps.
        #expect(frames.deck.height == 614)
    }

    @Test func wideWindowSitsSideBySide() {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 380)

        let frames = arrangement.frames(in: bounds, summarySize: fixedHeight(80), buttonsSize: fixedHeight(90))

        #expect(frames.deck.width == 396)
        #expect(frames.deck.maxX == 800)
        #expect(frames.deck.height == 380)
        #expect(frames.summary.maxX <= frames.deck.minX)
    }

    @Test func sideBySideIsRuledOutWhenTheColumnIsTooNarrow() {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 380)
        let wideButtons: (ProposedViewSize) -> CGSize = { _ in CGSize(width: 500, height: 90) }

        let sideBySide = arrangement.sideBySideFrames(
            in: bounds,
            summarySize: fixedHeight(80),
            buttonsSize: wideButtons
        )

        #expect(sideBySide == nil)
    }

    @Test func stackedSummaryNeverOverlapsTheButtons() {
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 200)

        let frames = arrangement.stackedFrames(in: bounds, summarySize: fixedHeight(150), buttonsSize: fixedHeight(120))

        #expect(frames.summary.maxY <= frames.buttons.minY)
        #expect(frames.deck.height == 0)
    }

    @Test func placementStartsFromTheBoundsOrigin() {
        let bounds = CGRect(x: 20, y: 50, width: 400, height: 800)

        let frames = arrangement.stackedFrames(in: bounds, summarySize: fixedHeight(80), buttonsSize: fixedHeight(90))

        #expect(frames.summary.origin == CGPoint(x: 20, y: 50))
        #expect(frames.buttons.maxY == 850)
    }
}
