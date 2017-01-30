uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform float time;
uniform float ttlScale;
uniform float animationParam1;
uniform float animationParam2;
uniform float animationParam3;
uniform float animationParam4;
uniform float animationParam5;
uniform float animationParam6;
uniform float animationParamTtlAbout;
uniform float animationParamTtlBlog;
uniform float animationParamTtlBookmarks;
uniform float animationParamTtlWorks;

attribute vec3 position;
attribute vec3 cubeCenter;
attribute vec3 cubeRandom;
attribute vec3 triangleRandom;
attribute vec3 triangleCenter;
attribute vec3 normal;
attribute float noiseValue;
attribute float vertexIndex;

attribute vec2 aboutPos;
attribute vec2 blogPos;
attribute vec2 bookmarksPos;
attribute vec2 worksPos;

varying vec4 vColor;

#pragma glslify: PI = require('./lib/PI.glsl')
#pragma glslify: map = require('./lib/map.glsl')
#pragma glslify: hsv2rgb = require('./lib/hsv2rgb.glsl')
#pragma glslify: rotateVec3 = require('./lib/rotateVec3.glsl')
#pragma glslify: easeInOutExpo = require('glsl-easings/exponential-in-out')
#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')


float getRad(float scale, float offset) {
  return map(mod(time * scale + offset, PI * 2.0), 0.0, PI * 2.0, -PI, PI, true);
}

float getAnimationParam(float animationParam, float randomValue) {
  float p = clamp(-map(randomValue, -1.0, 1.0, 0.0, 0.6, true) + animationParam * 1.5, 0.0, 1.0);
  p = easeInOutExpo(p);
  return p;
}

void setTtlAnimation(float animationParam, vec2 ttlPos, inout vec3 pos) {
  float p = getAnimationParam(animationParam, triangleRandom.x);
  if(p > 0.0) {
    pos = pos - triangleCenter * p;
    pos *= (1.0 - 0.01 * p * cubeRandom.x);
    float scale = 1.0 + (ttlScale * 20.0 * p - 1.0) * p;
    pos *= scale;
    float rad1 = getRad(40.0, noiseValue * 10.0);
    float rad2 = getRad(40.0, noiseValue * 10.0);
    pos = rotateVec3(pos, p * rad1, vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * rad2, vec3(0, 1.0, 0));
    pos.x *= 1.0 - p * 0.6;
    pos.z *= 1.0 - p * 0.6;
    vec3 n = rotateVec3(normal, p * rad1, vec3(1.0, 0, 0));
    n = rotateVec3(n, p * rad2, vec3(0, 1.0, 0));
    pos += (p * vec3(ttlPos * ttlScale, 0.0));
    float noise = snoise2(pos.xy / 300.0 / scale);
    pos += p * vec3(
      sin((time + noise) * 100.0) * 0.2 * scale,
      cos((time + noise) * 60.0) * 0.2 * scale,
      0
    );
  }
}

void main() {
  vec3 pos = position;
  vec3 n = normal;
  float rad1, rad2;

  // animation1
  float p = easeInOutExpo(animationParam1);
  if(p > 0.0) {
    rad1 = getRad(3.0, 0.0);
    rad2 = getRad(5.0, 0.0);
    pos = rotateVec3(pos, p * rad1, vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * rad2, vec3(0, 1.0, 0));
    n = rotateVec3(n, p * rad1, vec3(1.0, 0, 0));
    n = rotateVec3(n, p * rad2, vec3(0, 1.0, 0));
    pos += (p * sin(getRad(200.0, noiseValue * 200.0)) * noiseValue * 0.06 * normalize(pos));
  }

  // animation2
  p = getAnimationParam(animationParam2, cubeRandom.x);
  if(p > 0.0) {
    pos = pos - cubeCenter * p;
    pos *= (1.0 + p);
    rad1 = PI * 2.0 * sin(getRad(1.0, cubeRandom.x));
    rad2 = PI * 2.0 * sin(getRad(1.0, cubeRandom.y));
    pos = rotateVec3(pos, p * rad1, vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * rad2, vec3(0, 1.0, 0));
    n = rotateVec3(n, p * rad1, vec3(1.0, 0, 0));
    n = rotateVec3(n, p * rad2, vec3(0, 1.0, 0));
    vec3 cubeCenterTo = cubeRandom * 20.0;
    pos += (p * cubeCenterTo);
    pos = rotateVec3(pos, p * getRad(1.0, 0.0), vec3(0.3, 1.0, 0.2));
    pos += (p * sin(getRad(160.0, noiseValue * 160.0)) * noiseValue * 0.3 * normalize(cubeCenterTo - pos));
  }


  // animation3
  p = getAnimationParam(animationParam3, triangleRandom.x);
  if(p > 0.0) {
    pos = pos - triangleCenter * p;
    rad1 = getRad(40.0, triangleRandom.x);
    rad2 = getRad(40.0, triangleRandom.y);
    pos = rotateVec3(pos, p * rad1, vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * rad2, vec3(0, 1.0, 0));
    n = rotateVec3(n, p * rad1, vec3(1.0, 0, 0));
    n = rotateVec3(n, p * rad2, vec3(0, 1.0, 0));
    float radius = 30.0 * map(triangleRandom.y, -1.0, 1.0, 0.0, 1.0, true);
    float anim2CircleRad = getRad(6.0, triangleRandom.x * 6.0);
    pos += vec3(
      p * radius * cos(anim2CircleRad),
      p * 2.0 * sin(getRad(4.0, triangleRandom.y) * 10.0),
      p * radius * sin(anim2CircleRad)
    );
    pos = rotateVec3(pos, p * getRad(4.0, 0.0), vec3(0.3, 1.0, sin(time)));
    n = rotateVec3(n, p * getRad(4.0, 0.0), vec3(0.3, 1.0, sin(time)));
  }


  // animation4
  p = getAnimationParam(animationParam4, triangleRandom.x);
  if(p > 0.0) {
    pos = pos - triangleCenter * p;
    if(mod(vertexIndex, 3.0) > 0.0) {
      pos.z += (p * (4.0 * triangleRandom.z * sin(triangleRandom.z * 100.0)));
      pos = rotateVec3(pos, p * getRad(10.0, triangleRandom.x * 10.0), vec3(1.0, 0, 0));
      pos = rotateVec3(pos, p * getRad(10.0, triangleRandom.y * 10.0), vec3(0, 1.0, 0));
      pos += (p * sin(getRad(60.0, noiseValue * 60.0)) * noiseValue * 6.0 * normalize(pos));
    }
  }

  // animation5
  p = getAnimationParam(animationParam5, triangleRandom.x);
  if(p > 0.0) {
    pos = pos - (pos - normalize(pos) * 3.0) * p;
    rad1 = getRad(10.0, triangleRandom.x * 10.0);
    rad2 = getRad(10.0, triangleRandom.y * 10.0);
    pos = rotateVec3(pos, p * rad1, vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * rad2, vec3(0, 1.0, 0));
    n = rotateVec3(n, p * rad1, vec3(1.0, 0, 0));
    n = rotateVec3(n, p * rad2, vec3(0, 1.0, 0));
    pos += (p * sin(getRad(10.0, triangleRandom.z * 10.0)) * 3.0 * normalize(pos));
  }


  // animation6
  p = getAnimationParam(animationParam6, triangleRandom.x);
  if(p > 0.0) {
    pos = pos - triangleCenter * p;
    rad1 = getRad(30.0, triangleRandom.x * 10.0);
    rad2 = getRad(30.0, triangleRandom.y * 10.0);
    pos = rotateVec3(pos, p * rad1, vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * rad2, vec3(0, 1.0, 0));
    float triangleIndex = floor(vertexIndex / 3.0);
    float cubeIndex = mod(mod(triangleIndex, 41.0), 3.0);
    float size = 2.0 + cubeIndex * 2.0;
    float t = mod(time * 10.0 + triangleRandom.z * 10.0, 4.0);
    pos.x += (map(t, 0.0, 1.0, -1.0, 1.0, true) * size * p - size * p);
    pos.y += (map(t, 1.0, 2.0, -1.0, 1.0, true) * size * p - size * p);
    pos.x -= map(t, 2.0, 3.0, -1.0, 1.0, true) * size * p;
    pos.y -= map(t, 3.0, 4.0, -1.0, 1.0, true) * size * p;
    pos.z -= size * p;
    pos = rotateVec3(pos, p * PI * mod(triangleIndex, 2.0), vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * PI / 2.0 * mod(triangleIndex, 3.0), vec3(0, 1.0, 0));
    pos = rotateVec3(pos, p * PI / 2.0 * mod(triangleIndex, 4.0), vec3(0, 0, 1.00));
    pos = rotateVec3(pos, p * time * 2.0 * (cubeIndex + 1.0), vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * time * 2.0 * (cubeIndex + 1.0), vec3(0, 1.0, 0));
  }

  // title
  setTtlAnimation(animationParamTtlAbout, aboutPos, pos);
  setTtlAnimation(animationParamTtlBlog, blogPos, pos);
  setTtlAnimation(animationParamTtlBookmarks, bookmarksPos, pos);
  setTtlAnimation(animationParamTtlWorks, worksPos, pos);

  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);

  float len = length(pos);
  vColor = vec4(hsv2rgb(vec3(
    map(sin(getRad(2.0, noiseValue * 0.6 + len * (animationParam5 * 0.2 + animationParam6 * 0.2))), -1.0, 1.0, 0.0, 1.0, true),
    map(cos(getRad(3.0, noiseValue * 2.0 + len * (animationParam2 * 2.0 + animationParam3 * 3.0))), -1.0, 1.0, 0.3, 0.5, true),
    map(cos(getRad(1.0, noiseValue * 0.3)), -1.0, 1.0, 1.6, 2.0, true) + animationParam4 * 0.2
  )), 1.0);

  // light
  float diffuse  = clamp(dot(n, normalize(vec3(1.0, 1.0, 1.0))) , 0.5, 1.0);
  vColor *= vec4(vec3(diffuse), 1.0);
}
