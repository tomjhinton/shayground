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

float stroke(float x, float s, float w){
  float d = step(s, x+ w * .5) - step(s, x - w * .5);
  return clamp(d, 0., 1.);
}

float wiggly(float cx, float cy, float amplitude, float frequency, float spread){

  float w = sin(cx * amplitude * frequency * PI) * cos(cy * amplitude * frequency * PI) * spread;

  return w;
}


float circleDF(vec2 uv){
  vec2 centerPt = vec2(.5) - uv;
  float dist = length(centerPt);

  float slowTime = vTime * 0.2;


  float frequency = 16. ;
  float amplitude = 2. ;
  dist += wiggly(centerPt.x + vTime * .05, centerPt.y + vTime * .05, 2., 6., 0.005);
  return dist;
}



void main(){
  vec2 uv = (gl_FragCoord.xy - uResolution * .5) / uResolution.yy + 0.5;
  // vec2 uv = gl_FragCoord.xy / uResolution;
  // vec2 uv = vUv;
  vec3 color = vec3(0.);


  float circleFn = circleDF(uv);
  float circle = step(0.02, abs(circleFn - .25 ));

  vec3 c1 = vec3(0.75, 0.0, 0.5);
  vec3 c2 = vec3(1., 1., 0.);
  vec3 c3 = vec3(0., 0., 1.);


  color+= mix(c2, c1, length(uv)) + circle;



  vec4 tex = texture2D(uTexture, vUv);


 gl_FragColor =  vec4(color, 1.);

}
