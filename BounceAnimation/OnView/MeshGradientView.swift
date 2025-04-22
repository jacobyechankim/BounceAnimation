//
//  MeshGradientView.swift
//  BounceAnimation
//
//  Created by 0000 on 4/21/25.
//

import SwiftUI

struct MeshGradientView: View {
    var t: Float

    var body: some View {
        MeshGradient(width: 3, height: 3, points: [
            .init(0, 0), .init(0.3, 0), .init(1, 0),
            [customSin(-0.8...(-0.2), initialPhase: 0.439, angularFrequency: 0.342),
             customSin(0.3...0.7, initialPhase: 3.42, angularFrequency: 0.984)],
            [customSin(0.1...0.8, initialPhase: 0.239, angularFrequency: 0.084),
             customSin(0.2...0.8, initialPhase: 5.21, angularFrequency: 0.242)],
            [customSin(1.0...1.5, initialPhase: 0.939, angularFrequency: 0.94),
             customSin(0.4...0.8, initialPhase: 0.25, angularFrequency: 0.642)],
            [customSin(-0.8...0.0, initialPhase: 1.439, angularFrequency: 0.442),
             customSin(1.4...1.9, initialPhase: 3.42, angularFrequency: 0.984)],
            [customSin(0.3...0.6, initialPhase: 0.339, angularFrequency: 0.784),
             customSin(1.0...1.2, initialPhase: 1.22, angularFrequency: 0.772)],
            [customSin(1.0...1.5, initialPhase: 0.939, angularFrequency: 0.056),
             customSin(1.3...1.7, initialPhase: 0.47, angularFrequency: 0.342)]
        ], colors: [
            .yellow, .purple, Color( #colorLiteral(red: 0.0255561769, green: 0.9446052909, blue: 0.9651842713, alpha: 1) ),
            .purple, .red, .blue,
            .orange, .green, .mint
        ])
        .ignoresSafeArea()
    }

    private func customSin(_ range: ClosedRange<Float>, initialPhase: Float, angularFrequency: Float) -> Float {
        let t = t
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(angularFrequency * t + initialPhase)
    }
}

#Preview {
    MeshGradientView(t: 0)
}
