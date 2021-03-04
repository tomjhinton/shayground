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

float random(vec2 st)
{
  return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

//	Classic Perlin 2D Noise
//	by Stefan Gustavson
//
vec4 permute(vec4 x)
{
    return mod(((x*34.0)+1.0)*x, 289.0);
}


vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 *
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
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

vec3 sdEquilateralTriangle( in vec2 p )
{
  float slowTime = vTime * .5;
   float d = 0.0;
  vec2 st = p *2.-1.;

  // Number of sides of your shape
  int N = 9 ;

  // Angle and radius from the current pixel
  float a = atan(st.x,st.y)+PI ;
  float r = (2.* PI)/float(N) ;

  // Shaping function that modulate the distance
  d = cos(floor(.5+a/r)*r-a)*length(st);
  d += wiggly(st.x + vTime * .05, st.y + vTime * .05, 2., 16., 0.005);

  return  vec3(1.0-smoothstep(.4,.41,d));
}


float circleDF(vec2 uv){
  vec2 centerPt = vec2(.5) - uv;
  float dist = length(centerPt);

  float slowTime = vTime * 0.2;


  float frequency = 16. ;
  float amplitude = 2. ;
  dist += wiggly(centerPt.x + vTime * .05, centerPt.y + vTime * .5, 4., 32., (0.05 * sin(vTime))) ;
  return dist;
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

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
  mat2 rotation_matrix=mat2(  vec2(sin(rotation),-cos(rotation)),
                              vec2(cos(rotation),sin(rotation))
                              );
  uv -= pivot;
  uv= uv*rotation_matrix;
  uv += pivot;
  return uv;
}

void main(){
  // vec2 uv = (gl_FragCoord.xy - uResolution * .5) / uResolution.yy + 0.5;

  // vec2 uv = gl_FragCoord.xy / uResolution;
  vec2 uv = vUv;
  vec3 color = vec3(0.);
  float slowTime = vTime * .05;


  float circleFn = circleDF(uv);


  float circle = step(0.08, abs(circleFn - .25 ));
  vec3 triangle = sdEquilateralTriangle(vec2(uv.x, uv.y));

  vec3 c1 = vec3(0.75, (sin(vTime)+1.)/2., 0.5);
  vec3 c2 = vec3(1., (sin(vTime)+1.)/2., 0.);

  vec3 c3 = vec3(0.75, .3, (sin(vTime)+1.)/2.);
  vec3 c4 = vec3((sin(vTime)+1.)/2., 0., 1.);


  vec2 rote = rotateUV(vUv, vec2(.5), PI * slowTime);
  // color+= mix(c2, c1, length(uv)) + circle;
  color = fract(color);
  // triangle = fract(triangle);
  color= mix(c2, c1, length(uv)) * triangle;
  color += fract(color);
  color*= mix(c3, c4, length(uv)) + circle;


float strength = cnoise(rote * 30.0  );


  vec4 tex = texture2D(uTexture, vUv *sin(slowTime* .05));
    color *= tex.rgb;
    color.rgb += strength;

 gl_FragColor =  vec4(color, .4) ;

}
