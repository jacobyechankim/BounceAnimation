//
//  AnimatedPath.swift
//  BounceAnimation
//
//  Created by 0000 on 4/21/25.
//

import SwiftUI

struct AnimatedRectangle: Shape {
    var size: CGSize
    var padding: Double = 8.0
    var cornerRadius: CGFloat
    var t: CGFloat

    var animatableData: CGFloat {
        get { t }
        set { t = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let width = size.width
        let height = size.height
        let radius = cornerRadius

        // Define the initial points
        let initialPoints = [
            CGPoint(x: padding + radius, y: padding),
            CGPoint(x: width * 0.25 + padding, y: padding),
            CGPoint(x: width * 0.75 + padding, y: padding),
            
            CGPoint(x: width - padding - radius, y: padding),
            CGPoint(x: width - padding, y: padding + radius),
            CGPoint(x: width - padding, y: height * 0.25 - padding),
            CGPoint(x: width - padding, y: height * 0.75 - padding),
            CGPoint(x: width - padding, y: height - padding - radius),
            
            CGPoint(x: width - padding - radius, y: height - padding),
            CGPoint(x: width * 0.75 - padding, y: height - padding),
            CGPoint(x: width * 0.25 - padding, y: height - padding),
            
            CGPoint(x: padding + radius, y: height - padding),
            CGPoint(x: padding, y: height - padding - radius),
            CGPoint(x: padding, y: height * 0.75 - padding),
            CGPoint(x: padding, y: height * 0.25 - padding),
            CGPoint(x: padding, y: padding + radius)
        ]
        
        // Move the points
        var randomFrequency: CGFloat = 0.8
        
        let points = initialPoints.map { point in
            if randomFrequency > 1.3 {
                randomFrequency = 0.8
            } else {
                randomFrequency += 0.1
            }
            return CGPoint(
                x: point.x + 10 * sin(randomFrequency * t + point.y * 0.1),
                y: point.y + 10 * sin(randomFrequency * t + point.x * 0.1)
            )
        }
        

        // Draw path
        var path = Path()

        path.move(to: CGPoint(x: padding, y: padding + radius))
        // Top edge
        for point in points[0...3] {
            path.addLine(to: point)
        }
        // Right edge
        for point in points[4...7] {
            path.addLine(to: point)
        }
        // Bottom edge
        for point in points[8...10] {
            path.addLine(to: point)
        }
        // Left edge
        for point in points[11...14] {
            path.addLine(to: point)
        }

        path.closeSubpath()

        return path
    }
}
