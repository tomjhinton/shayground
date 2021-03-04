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



void main(){
  // vec2 uv = (gl_FragCoord.xy - uResolution * .5) / uResolution.yy + 0.5;
  // vec2 uv = gl_FragCoord.xy / uResolution;
  vec2 uv = vUv;
  vec3 color = vec3(uv.x, uv.y, 1.);


  float amount = 5. ;

  float fractX = fract(sin(uv.x * amount ) +uv.y + PI * amount + cos(vTime));
  //float fractY = fract(uv.y * amount);


  float circle = smoothstep(fractX + sin(vTime) + noise(sin(uv.x)) , 0.3 + noise(sin(uv.y)), circleDF(uv) -cos(vTime));
  color+=circle;
  color = vec3(fract(color));
  color *= vec3(fract(color));
  color = vec3(fract(color));
  color.r += noise(cos(vTime));

 gl_FragColor = vec4(color, .8);

}
