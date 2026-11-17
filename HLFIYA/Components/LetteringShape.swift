//
//  LetteringShape.swift
//  HLFIYA
//

import SwiftUI

/// Yellowtail lettering drawn from the font's outlines, keeping its proportions and centered in
/// whatever rectangle it's given.
///
/// With a stroke width, the shape is the band around the letters' edges instead, so a neon
/// tube or glow can be filled at a weight that matches the lettering's size.
nonisolated struct LetteringShape: Shape {
    let lettering: NeonLettering
    var part = LetteringPart.outline

    /// The width of the band around the letters, relative to their font size, or `nil` for
    /// the letters themselves.
    var strokeWidth: Double?

    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width / lettering.aspectRatio, rect.height)
        let origin = CGPoint(
            x: rect.midX - scale * lettering.aspectRatio / 2,
            y: rect.midY - scale / 2
        )

        func point(_ relativeX: Double, _ relativeY: Double) -> CGPoint {
            CGPoint(x: origin.x + relativeX * scale, y: origin.y + relativeY * scale)
        }

        let strokes = part == .outline ? lettering.outline : lettering.pen
        var path = Path()
        for stroke in strokes where stroke.count >= 8 {
            path.move(to: point(stroke[0], stroke[1]))
            for index in stride(from: 2, through: stroke.count - 6, by: 6) {
                path.addCurve(
                    to: point(stroke[index + 4], stroke[index + 5]),
                    control1: point(stroke[index], stroke[index + 1]),
                    control2: point(stroke[index + 2], stroke[index + 3])
                )
            }
            if part == .outline {
                path.closeSubpath()
            }
        }

        guard let strokeWidth else { return path }
        let fontSize = scale * lettering.fontSizeOverHeight
        return path.strokedPath(StrokeStyle(lineWidth: fontSize * strokeWidth, lineCap: .round, lineJoin: .round))
    }
}

#Preview {
    ZStack {
        LetteringShape(lettering: .getReady)
            .fill(.pink.opacity(0.3))
        LetteringShape(lettering: .getReady, part: .pen)
            .stroke(.pink, lineWidth: 1)
    }
    .aspectRatio(NeonLettering.getReady.aspectRatio, contentMode: .fit)
    .padding()
}
