precision mediump float;

uniform sampler2D texture;
uniform float noiseCoefficient;
uniform float time;
uniform vec2 resolution;

varying vec2 vUv;

#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')

void main(){
  float noise = snoise2(gl_FragCoord.xy / resolution.y / 50.0);
  vec2 texCoord = vec2(
    vUv.x + (sin((time + noise) * 100.0) * 2.0 / resolution.x) * noiseCoefficient,
    vUv.y + (cos((time + noise) * 60.0) * 2.0 / resolution.y) * noiseCoefficient
  );
  gl_FragColor = texture2D(texture, texCoord);
}
