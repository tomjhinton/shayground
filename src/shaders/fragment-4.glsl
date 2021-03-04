//https://www.youtube.com/watch?v=W5gR_Kww2k8

const float PI = 3.1415926535897932384626433832795;
uniform vec3 uColor;
uniform vec3 uPosition;
uniform vec3 uRotation;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform vec2 uMouse;


varying vec2 vUv;
varying float vElevation;
varying float vTime;

float circleDF(vec2 uv){
  vec2 centerPt = vec2(.5) - uv;
  float dist = length(centerPt);
  return dist;
}

float rand(float x){
  return fract(sin(x)*100.);
}

//perlinish
float noise(float x){
  float n = 0.;

  float i = floor(x);  // integer
  float f = fract(x); //fraction

  n = rand(i);

  n = mix(rand(i), rand(i + 1.0), f);
  n = mix(rand(i), rand(i + 1.00), smoothstep(0., 1., f));

  return n ;

}
float pModPolar(inout vec2 p, float repetitions) {
    float angle = 2.*PI/repetitions;
    float a = atan(p.y, p.x) + angle/2.;
    float r = length(p);
    float c = floor(a/angle);
    a = mod(a,angle) - angle/2.;
    p = vec2(cos(a), sin(a))*r;
    // For an odd number of repetitions, fix cell index of the cell in -x direction
    // (cell index would be e.g. -5 and 5 in the two halves of the cell):
    if (abs(c) >= (repetitions/2.)) c = abs(c);
    return c;
}
void pMod2(inout vec2 p, vec2 size){
  p = mod(p, size) -size * 0.5;
}


void main(){
  // vec2 uv = (gl_FragCoord.xy - uResolution * .5) / uResolution.yy + 0.5;
  vec2 uv = vUv;
  vec3 color = vec3(0.);

  float amount = 5. * (cos(vTime) * .05);
  pMod2(uv, vec2(1.));
  // pModPolar(uv, 8. +sin(vTime));
  float fractX = fract(sin(uv.x * amount ) +uv.y * amount);
  //float fractY = fract(uv.y * amount);


  float circle = step(0.25, circleDF(uv));

  color = vec3(fractX,cos(vTime) * noise(uv.y), uv.x);
  // color+=circle;
  color.g += mod(color.r, uv.x);
  color.g += mod(color.g, (uv.y + cos(vTime)));
  // pModPolar(uv, cos(vTime));
  uv.x+= sin(vTime);
  uv.y+= cos(vTime);
  color.r += mod(color.g, (uv.y + cos(vTime)));
  color.b += mod(color.g, (uv.y + cos(vTime)));
  color.g += mod(color.r, (uv.y + sin(vTime)));
  color.r += mod(color.b, (uv.x + sin(vTime)));
  color.b += mod(color.g, (uv.x + sin(vTime)));

  color.b += mod(color.b, (uv.x + cos(vTime)));
  color *= vec3(fract(vec3(color)));
  color.g += mod(color.g, (uv.y + sin(vTime * uv.x)));
  color.r += mod(color.r, (uv.x + sin(vTime)));

  color.b += mod(color.b, (uv.y + cos(vTime * noise(uv.y))));
  color += vec3(fract(vec3(color)));
  color /= vec3(circle);
 gl_FragColor = vec4(color, .8);

}
