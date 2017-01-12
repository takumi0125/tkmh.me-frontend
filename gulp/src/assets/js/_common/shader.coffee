# HSVをRGBに変換
tkmh.shader.hsv2rgb = """
vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
"""

# map
tkmh.shader.map = """
float map(float value, float inputMin, float inputMax, float outputMin, float outputMax, bool clamp) {
  if(clamp == true) {
    if(value < inputMin) return outputMin;
    if(value > inputMax) return outputMax;
  }

  float p = (outputMax - outputMin) / (inputMax - inputMin);
  return ((value - inputMin) * p) + outputMin;
}
"""

# rotate vec3
tkmh.shader.rotateVec3 = """
vec3 rotateVec3(vec3 p, float angle, vec3 axis){
  vec3 a = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float r = 1.0 - c;
  mat3 m = mat3(
    a.x * a.x * r + c,
    a.y * a.x * r + a.z * s,
    a.z * a.x * r - a.y * s,
    a.x * a.y * r - a.z * s,
    a.y * a.y * r + c,
    a.z * a.y * r + a.x * s,
    a.x * a.z * r + a.y * s,
    a.y * a.z * r - a.x * s,
    a.z * a.z * r + c
  );
  return m * p;
}
"""

# easeInOutExpo
tkmh.shader.easeInOutExpo = """
float easeInOutExpo(float t, float b, float c, float d) {
  if (t == 0.0) return b;
  if (t == d) return b+c;
  if ((t /= d / 2.0) < 1.0) return c / 2.0 * pow(2.0, 10.0 * (t - 1.0)) + b;
  return c / 2.0 * (-pow(2.0, -10.0 * --t) + 2.0) + b;
}
"""

# define PI
tkmh.shader.definePI = """
#define PI 3.1415926535897932384626433832795
"""


# simprex noise 2D
tkmh.shader.simplexNoise2D = """
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float simplexNoise2D(vec2 v) {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
  // First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

  // Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

  // Gradients: 41 points uniformly over a line, mapped onto a diamond.
  // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  // Normalise gradients implicitly by scaling m
  // Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

  // Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}
"""


tkmh.shader.TakumiShader =
  transparent: true
  uniforms:
    time: { type: 'f', value: 0 }
    ttlScale: { type: 'f', value: 1 }
    animationParam1: { type: 'f', value: 0 }
    animationParam2: { type: 'f', value: 0 }
    animationParam3: { type: 'f', value: 0 }
    animationParam4: { type: 'f', value: 0 }
    animationParam5: { type: 'f', value: 0 }
    animationParam6: { type: 'f', value: 0 }
    animationParamTtlAbout: { type: 'f', value: 0 }
    animationParamTtlBlog: { type: 'f', value: 0 }
    animationParamTtlBookmarks: { type: 'f', value: 0 }
    animationParamTtlWorks: { type: 'f', value: 0 }
  fragmentShader: """
precision mediump float;
varying vec4 vColor;

void main(){
  gl_FragColor = vColor;
}
"""
  vertexShader: """
uniform mat4 modelViewMatrix;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;
uniform float time;
uniform float ttlScale;
uniform float animationParamDefault;
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

#{tkmh.shader.definePI}

#{tkmh.shader.easeInOutExpo}

#{tkmh.shader.map}

#{tkmh.shader.hsv2rgb}

#{tkmh.shader.rotateVec3}

float getRad(float scale, float offset) {
  return map(mod(time * scale + offset, PI * 2.0), 0.0, PI * 2.0, -PI, PI, true);
}

float getAnimationParam(float animationParam, float randomValue) {
  float p = clamp(-map(randomValue, -1.0, 1.0, 0.0, 0.6, true) + animationParam * 1.5, 0.0, 1.0);
  p = easeInOutExpo(p, 0.0, 1.0, 1.0);
  return p;
}

void setTtlAnimation(float animationParam, vec2 ttlPos, inout vec3 pos) {
  float p = getAnimationParam(animationParam, triangleRandom.x);
  if(p > 0.0) {
    pos = pos - triangleCenter * p;
    pos *= (1.0 - 0.01 * p / ttlScale * cubeRandom.x);
    float rad1 = getRad(40.0, noiseValue * 10.0);
    float rad2 = getRad(40.0, noiseValue * 10.0);
    pos = rotateVec3(pos, p * rad1, vec3(1.0, 0, 0));
    pos = rotateVec3(pos, p * rad2, vec3(0, 1.0, 0));
    pos.x *= 1.0 - p * 0.6;
    pos.z *= 1.0 - p * 0.6;
    vec3 n = rotateVec3(normal, p * rad1, vec3(1.0, 0, 0));
    n = rotateVec3(n, p * rad2, vec3(0, 1.0, 0));
    pos += (p * vec3(ttlPos * ttlScale, 0.0));
  }
}

void main() {
  vec3 pos = position;
  vec3 n = normal;
  float rad1, rad2;

  // animation1
  float p = easeInOutExpo(animationParam1, 0.0, 1.0, 1.0);
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
"""

tkmh.shader.PostProcessShader =
  transparent: true
  # wireframe: true
  uniforms:
    time: { type: 'f', value: 0 }
    noiseCoefficient: { type: 'f', value: 1 }
    resolution: { type: 'v' }
    texture: { type: 't' }
  fragmentShader: """
precision mediump float;
uniform sampler2D texture;
uniform float noiseCoefficient;
uniform float time;
uniform vec2 resolution;
varying vec2 vUv;

#{tkmh.shader.simplexNoise2D}

void main(){
  float noise = simplexNoise2D(gl_FragCoord.xy / resolution.y / 50.0);
  vec2 texCoord = vec2(
    vUv.x + (sin((time + noise) * 100.0) * 2.0 / resolution.x) * noiseCoefficient,
    vUv.y + (cos((time + noise) * 60.0) * 2.0 / resolution.y) * noiseCoefficient
  );
  gl_FragColor = texture2D(texture, texCoord);
}
"""
  vertexShader: """
attribute vec3 position;
attribute vec2 uv;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
varying vec2 vUv;

void main() {
  vUv = uv;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
"""


tkmh.shader.ThumbShader =
  transparent: true
  side: THREE.DoubleSide
  uniforms:
    animationParam: { type: 'f', value: 0 }
    texture: { type: 't' }
  fragmentShader: """
precision mediump float;
uniform sampler2D texture;
varying vec2 vUv;

void main(){
  gl_FragColor = texture2D(texture, vUv);
}
"""
  vertexShader: """
attribute vec3 position;
attribute vec2 uv;
attribute float vertexIndex;
attribute float noiseValue;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform float animationParam;
varying vec2 vUv;

#{tkmh.shader.easeInOutExpo}

#{tkmh.shader.map}

float getAnimationParam(float animationParam, float randomValue) {
  float p = clamp(-map(randomValue, -1.0, 1.0, 0.0, 0.5, true) + animationParam * 1.6, 0.0, 1.0);
  p = easeInOutExpo(p, 0.0, 1.0, 1.0);
  return p;
}

void main() {
  vUv = uv;
  vec3 pos = position;
  float p = getAnimationParam(animationParam, noiseValue);
  pos.y += p * -120.0;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}
"""
