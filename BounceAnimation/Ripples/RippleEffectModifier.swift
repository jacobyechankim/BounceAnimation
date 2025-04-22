//
//  RippleEffectModifier.swift
//  BounceAnimation
//
//  Created by 0000 on 4/21/25.
//

import SwiftUI
import Foundation

// ViewModifier that animates frame and provides it to the 'elapsedTime' of RippleModifier and applies complete ripple animation to its content,
// whenever trigger value changes.
struct RippleEffect<T: Equatable>: ViewModifier {
    var trigger: T
    var origin: CGPoint
    var duration: TimeInterval = 4

    init(at origin: CGPoint, trigger: T) {
        self.origin = origin
        self.trigger = trigger
    }

    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration
        
        // The keyframeAnimator view modifier makes it easy to run animations based on external changes, like gestures by trigger value.
        // It Animates the elapsedTime from zero to its final duration value, whenever the trigger value updates.
        // This way, at every step of the animation, RippleModifier will be passed the current time and the origin point at which I touched the view.
        // More info at KeyFrame WWDC video: https://www.youtube.com/watch?v=NFmQjc7ia4Y&t=909s
        content.keyframeAnimator(initialValue: 0, trigger: trigger) { view, elapsedTime in
            view.modifier(RippleModifier(origin: origin, elapsedTime: elapsedTime, duration: duration))
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}


// ViewModifier that applies a ripple effect at specific elapsedTime to its content
struct RippleModifier: ViewModifier {
    //parameters to the shader function Ripple
    var origin: CGPoint
    var elapsedTime: TimeInterval
    var duration: TimeInterval

    var amplitude: Double = 12
    var frequency: Double = 15
    var decay: Double = 1
    var speed: Double = 500
    
    var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.Ripple(.float2(origin), .float(elapsedTime), .float(amplitude),
            .float(frequency), .float(decay), .float(speed))
        let maxSampleOffset = maxSampleOffset
        
        content.visualEffect { view, geometry in
            // .layerEffect: Returns a new visual effect that applies shader to self as a filter on the raster layer created from self.
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0 < elapsedTime && elapsedTime < duration
            )
        }
    }
}

extension View {
    
    //  1. What is modifier()?
    //
    //      It returns modified self as ModifiedContent<Self,SpatialPressingGestureModifier> whose type is 'some View'.
    //      look at this:
    //              struct ModifiedContent<Content, Modifier> {~~}
    //              extension ModifiedContent : View where Content : View, Modifier : ViewModifier {~~}
    //
    //      func modifier is provided default implementation in extension of View.
    //      The implementation is simple: init ModifiedContent with self and given parameter.
    //
    //      we can call this just right after view like:
    //              someFuckView
    //                  .modifier(customSomeViewModifier(someParamsHere:~~))
    //      which is annoying.
    
    //      So, most custom viewModifier is applied in the project this way (i guess):
    //          1.  extension View with func whose params are params of custom view modifier and which returns 'some View'.
    //          2.  call that custom one in modifier()
    //
    //      What has changed?
    //              someFuckView
    //                  .theFuncInExtensionView(params)
    //      Easy and Clean.
    //
    //  2. What is going here under the hood?
    //
    //      someFuckView.theFuncInExtensionView() is just structInstance.method().
    //      It returns type of ContentModified<someFuckview.Self, customSomeViewModifierHere>.
    //      That is just SomeStruct<T,U>: View as extension of ModifiedContent insists.
    //      Then, parent struct, that might conform to View, and his viewbuilder will use this some View to build his body.
    
    func onPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
        modifier(SpatialPressingGestureModifier(action: action))
    }
}

struct SpatialPressingGestureModifier: ViewModifier {
    @State var currentLocation: CGPoint?
    var onPressingChanged: (CGPoint?) -> Void

    init(action: @escaping (CGPoint?) -> Void) {
        self.onPressingChanged = action
    }

    func body(content: Content) -> some View {
        let gesture = SpatialPressingGesture(location: $currentLocation)

        content
            .gesture(gesture)
            .onChange(of: currentLocation, initial: false) { _, location in
                onPressingChanged(location)
            }
    }
}

struct SpatialPressingGesture: UIGestureRecognizerRepresentable {
    @Binding var location: CGPoint?

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0
        recognizer.delegate = context.coordinator

        return recognizer
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIGestureRecognizerType, context: Context) {
        switch recognizer.state {
        case .began:
            location = context.converter.localLocation
        case .ended, .cancelled, .failed:
            location = nil
        default:
            break
        }
    }
}


