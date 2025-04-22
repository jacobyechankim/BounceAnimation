//
//  PlayingPhaseAnimator.swift
//  BounceAnimation
//
//  Created by 0000 on 4/23/25.
//

import SwiftUI

struct PlayingPhaseAnimator: View {
    var body: some View {
        Circle()
            .fill(LinearGradient(colors: [.red, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            .phaseAnimator([false, true]) { ww, chromaRotate in
                ww
                    .scaleEffect(1, anchor: chromaRotate ? .bottom : .topTrailing)
                    .hueRotation(.degrees(chromaRotate ? 600 : 0))
            } animation: { chromaRotate in
                    .easeInOut(duration: 5)
            }

    }
}

#Preview {
    PlayingPhaseAnimator()
}
