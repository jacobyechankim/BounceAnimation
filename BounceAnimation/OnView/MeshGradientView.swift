//
//  MeshGradientView.swift
//  BounceAnimation
//
//  Created by 0000 on 4/21/25.
//

import SwiftUI

// MARK: AnimatedMeshGradientView

/// MeshGradientView with animation.
///
/// Pass Binding gradientTrigger to trigger animation of MeshGradientView.
/// You can assign speed of animation whose default value is 1.0.
/// The speed would be proportional to the temperature.
/// Duration should be assign according to matching algorithm.
struct AnimatedMeshGradientView: View {
    @Binding var gradientTrigger: Int
    var speed: Double = 1.0
    var duration: Double = 300  // 300 sec
    
    var body: some View {
        MeshGradientView(t: 0)
          .keyframeAnimator(
            initialValue: 0,
            trigger: gradientTrigger
          ) { view, elapsed in
            // wrap the original “view” if you need it, or just ignore it:
            MeshGradientView(t: speed * elapsed)
          } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
          }
    }
}


// MARK: MeshGradientView

/// MeshGradientView with moving points at specific time.
struct MeshGradientView: View {
    let t: TimeInterval
    
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
            Color( #colorLiteral(red: 0.7860132456, green: 0.9615804553, blue: 0.7888813615, alpha: 1) ), Color( #colorLiteral(red: 0.6287890077, green: 0.911888659, blue: 0.9646195769, alpha: 1) ), Color( #colorLiteral(red: 0.9988270402, green: 0.7153211236, blue: 0.7090778947, alpha: 1) ),
            Color( #colorLiteral(red: 0.8746655583, green: 0.7890433669, blue: 0.9695464969, alpha: 1) ), Color( #colorLiteral(red: 0.6558250189, green: 0.645693481, blue: 0.9801579118, alpha: 1) ), Color( #colorLiteral(red: 0.8668988347, green: 0.9593016505, blue: 0.88291502, alpha: 1) ),
            Color( #colorLiteral(red: 0.0957409516, green: 0.2509717643, blue: 0.9948127866, alpha: 1) ), Color( #colorLiteral(red: 0.0255561769, green: 0.9446052909, blue: 0.9651842713, alpha: 1) ), Color( #colorLiteral(red: 0.881765306, green: 0.2532434165, blue: 0.8800789714, alpha: 1) )
        ])
        .scaleEffect(1.3)
        .ignoresSafeArea()
    }
    
    private func customSin(_ range: ClosedRange<Float>, initialPhase: Float, angularFrequency: Float) -> Float {
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(angularFrequency * Float(t) + initialPhase)
    }
}


#Preview {
    @Previewable @State var gradientTrigger: Int = 0
    AnimatedMeshGradientView(gradientTrigger: $gradientTrigger)
        .overlay {
            Text("trigger: \(gradientTrigger)")
                .padding()
                .onTapGesture {
                    gradientTrigger += 1
                }
        }
}
