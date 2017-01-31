attribute vec3 position;
attribute vec2 uv;
attribute float vertexIndex;
attribute float noiseValue;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform float animationParam;

varying vec2 vUv;

#pragma glslify: map = require('./lib/map.glsl')
#pragma glslify: easeInOutExpo = require('glsl-easings/exponential-in-out')

float getAnimationParam(float animationParam, float randomValue) {
  float p = clamp(-map(randomValue, -1.0, 1.0, 0.0, 0.5, true) + animationParam * 1.6, 0.0, 1.0);
  p = easeInOutExpo(p);
  return p;
}

void main() {
  vUv = uv;
  vec3 pos = position;
  float p = getAnimationParam(animationParam, noiseValue);
  pos.y += p * -120.0;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}
