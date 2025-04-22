//
//  RippleEffect.metal
//  BounceAnimation
//
//  Created by 0000 on 4/21/25.
//

#include <SwiftUI/SwiftUI.h>
using namespace metal;

/*
    Shader integration in SwiftUI

    The Ripple function below in this metal file returns half4 and will be used in ViewModifier.
    It is applied by creating Shader Instance with this func and passing it to func layerEffect.
 
            func layerEffect(
                _ shader: Shader,
                maxSampleOffset: CGSize,
                isEnabled: Bool = true
            ) -> some VisualEffect
 
    1. shader:
        `Shader` is a SwiftUI struct which references a Metal function of signature:
                [[ stitchable ]] half4 name(float2 position, SwiftUI::Layer layer, args...)
 
 
        1.1 Dive into this shader function (not deep)
            First, the parameters position and layer are required.
            position is the each pixel's position that Shader will work on.
            SwiftUI::Layer type is defined in the <SwiftUI/SwiftUI.h> header file.
            It exports a single sample() function that returns a linearly-filtered pixel value from a position in the source content, as a premultiplied RGBA pixel value:
                    namespace SwiftUI {
                        struct Layer {
                        half4 sample(float2 position) const;
                        };
                    };
            The function should return the color mapping to the destination pixel, typically by sampling one or more pixels from layer at location(s) derived from position and them applying some kind of transformation stuffs to produce a new color.
 
 
        Create Shader instance like:
                let shader = ShaderLibrary.Ripple(.float2(origin), .float(elapsedTime), ...)
        Note: we don't provide 'position' and 'layer' here. They are provided automatically by Swift in layerEffect.
        
 
        1.2 LayerEffect behind the scenes
            let's dive into layerEffect itself before looking into other parameters.
            layerEffect returns a new 'some VisualEffect' that applies Shader to View as a filter on the 'raster layer' created from View.
            Type 'some VisualEffect' will be used in view modifier '.visualEffect'.

            Raster layer is a pixel‑based (bitmap) representation of a view’s contents.
                (래스터: [TV] 래스터 ((브라운관의 주사선으로 구성된 화상(畵像))); [컴퓨터] 점방식 ((음극(선)관 등의 화면 위의 화상을 만드는 데 쓰이는 수평선의 집합))
            SwiftUI handles rendering views by calculating vectors such as bezier curve in normal daily life.
            So user can zoom in-out the screen without breaking resolution.
            But when layerEffect is called, SwiftUI creates a raster layer from the contents.
            Instead of describing shapes and text via vector instructions, the entire view hierarchy is rendered into a texture of individual pixels.
            
            Why raster layer but not vectors?
            Because it is efficient to apply shader per-pixel calculation and read-write RGBA with every pixel using GPU.
 
            layerEffect applies Shader to View by invoking given Shader on each pixel, passing:
                 - position: destination pixel coordinates
                 - layer: the original rasterized contents (Layer.sample(x,y) returns half4 RGBA of that layer)
                 - any extra args we defined (amplitude, frequency, decay, speed ...)
         
            Workflow behind the scenes:
                SwiftUI View -> render into a CALayer-backed texture -> Metal shader via `layerEffect` -> read/write pixel data -> composite back into the final display.
     
 
    2. maxSampleOffset:    tells the system how far the shader can sample from destination coordinates, which optimizes calculation i think.
 
    3. isEnabled:          toggles the effect on or off.
 */

[[ stitchable ]]
half4 Ripple(
             //  (float, float) 2D vector (x, y)
    float2 position,
             //  layer.sample(newPosition) -> 좌표에 해당하는 텍스처 색상을 읽어와 half4(RGBA)의 벡터 형태로 반환
             //  half: 16 bit floating point 타입    (half-float-double <-> 16bit-32bit-64bit)
    SwiftUI::Layer layer,
             
             
    float2 origin,
    float elapsedTime,
             
             //  Damped sine wave compositions
    float amplitude,
    float frequency,
    float decay,
    float speed
) {
    // The distance of the current pixel position from origin.
    float distance = length(position - origin);
    float delay = distance / speed;

    // a sine wave with exponential decay as time passes and spatial effect ~ r^-2.
    float m = max(0.5, delay) / 0.5;

    float spatialDecay = 1 / m / m;
    float delayedTime = max(0.0, elapsedTime - delay);
    float rippleAmount = amplitude * sin(frequency * delayedTime) * exp(-decay * elapsedTime) * spatialDecay;

    // normal vector in direction of fucking off origin.
    float2 n = normalize(position - origin);

    // The pixel at 'position' will be colored by the color of referencePosition.
    // The referencePosition moves around the position by amount of damped sine wave.
    // Therefore, every pixel in the layer will look like
    // oscillating in direction of fucking in or off origin.
    float2 referencePosition = position + rippleAmount * n;

    // Sample the layer at the new position.
    half4 color = layer.sample(referencePosition);

    // Lighten or darken the color based on the ripple amount and its alpha
    // component.
    color.rgb += 0.2 * (rippleAmount / amplitude) * color.a;

    return color;
}



//  To-Do: multi waves implementation on UI
//  This Shader provides superposition of multi waves.
#define MAX_WAVES 8

[[ stitchable ]]
half4 MultiRipple(
    float2 position,
    SwiftUI::Layer layer,
    constant float2 *origins,       // 파문 중심들
    constant float  *startTimes,    // 파문 시작 시각들
    uint           waveCount,       // 활성 wave 개수
    float          currentTime,     // 셰이더 시간
    float          amplitude,
    float          frequency,
    float          decay,
    float          speed
) {
  float2 disp = float2(0.0);
  for (uint i = 0; i < waveCount; ++i) {
    float2 o = origins[i];
    float dt = currentTime - startTimes[i];
    if (dt <= 0) continue;
    float d = length(position - o);
    float t = max(0.0, dt - d/speed);
    float wave = amplitude * sin(frequency*t) * exp(-decay*t);
    disp += wave * normalize(position - o);
  }
  float2 newPos = position + disp;
  half4 color = layer.sample(newPos);
  // optional highlight effect
  color.rgb += 0.3 * (length(disp)/amplitude) * color.a;
  return color;
}

