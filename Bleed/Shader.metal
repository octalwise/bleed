#include <metal_stdlib>
using namespace metal;
#include "Perlin.metalh"

[[ stitchable ]] half4 frag(
  float2 pos,
  half4 cur,
  float2 size,
  float time,
  float strength,
  float pulseOn,
  half4 color
) {
  float2 fpos = (pos / size) * 2 - 1;

  float dist = length(fpos);
  float a = dist + strength * 0.2 - 1.0;
  if (a <= -0.2) return half4(0.0);

  float noise = perlin(float3(fpos * 5.0, time * 0.1));
  a += noise * 0.1;
  if (a <= -0.03) return half4(0.0);

  if (pulseOn == 1.0) {
    float wavet = time * 0.5 * 1.0;
    float wave = sin(wavet + 0.4 * sin(wavet));
    float pulse = wave * 0.3 * pow(strength, 2.0);

    a += pulse * 0.05;
    a *= strength * (pulse + 1.0);
  } else {
    a *= strength;
  }

  return color * half4(a);
}
