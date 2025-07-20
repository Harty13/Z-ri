//
//  WavyShader.metal
//  Züri
//
//  Created by Erik Schnell on 18.03.2025.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
float2 wave(float2 position, float time, float amount) {
    return position - float2(0, sin(position.x * 0.3 + time * 3) * 2 * amount);
}
