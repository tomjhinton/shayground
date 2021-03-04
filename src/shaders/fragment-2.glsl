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

vec3 cosPalette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

void main(){

  vec2 uv = (gl_FragCoord.xy - uResolution * .5) / uResolution.yy + 0.5;
  vec3 color = vec3(0.);
  vec3 yellow = vec3(1.,1.,0);
  vec3 pink = vec3(1., .41, .78);


  float amount = 7.;
  float slantR = uv.x + uv.y ;
  float slantL = uv.x - uv.y ;

  float tau = PI * 2.;
  tau+= sin(vTime) * 2.;
  float t = vTime * .125;

  slantL+= tau * 0.05;




  float wave = sin(slantR * tau) * cos(slantL * tau);

  float waves2 = sin(slantR / tau) * PI + cos(slantL * tau) + cos(slantR * tau) * sin(slantL / tau) * PI;


  // float circle = step(0.25, circleDF(uv));

  vec3 grid = vec3(
      fract(slantR * amount) + wave *
      fract(slantL* amount));



  vec3 gradient = mix(pink, yellow, grid);
  color+=gradient;


  vec2 colorDots = vec2(uv.y, 0.25);
  float circle = smoothstep(
    0.025,
    0.1,
    circleDF(fract(1. - uv * amount * 0.75 + waves2)));


  vec3 dots = vec3(circle);
  // color += gradient;
  color /=   dots;

  vec3 cPalette = cosPalette( 0.5,
      color + vec3(0.0, 0.0, 0.75) * slantL  , //brightness
      vec3(.0), //contrast
      vec3(.5), // osc
      vec3(.5, .5, 1.)  // phase
      );

 gl_FragColor = vec4(cPalette,1.);

}
