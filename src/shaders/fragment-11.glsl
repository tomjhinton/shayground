const float PI = 3.1415926535897932384626433832795;
uniform vec3 uColor;
uniform vec3 uPosition;
uniform vec3 uRotation;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform vec2 uMouse;

varying float vDistort;
varying vec2 vUv;
varying float vElevation;
varying float vTime;


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

float wiggly(float cx, float cy, float amplitude, float frequency, float spread){

  float w = sin(cx * amplitude * frequency * PI) * cos(cy * amplitude * frequency * PI) * spread;

  return w;
}

vec3 shape( in vec2 p )
{
  float slowTime = vTime * .05;
  float d = 0.0;
  vec2 st = p *2.-1.;

  // Number of sides of your shape
  int N = 4 ;

  // Angle and radius from the current pixel
  float a = atan(st.x,st.y)+PI ;
  float r = (2.* PI)/float(N) ;

  // Shaping function that modulate the distance
  d = cos(floor(.5+a/r)*r-a)*length(st);
  d += wiggly(st.x + vTime * .05, st.y + vTime * .005, 2., 16., 1.5 * sin(slowTime));



  return  vec3(1.0-smoothstep(.4,.81,d));
}

float triangleDF(vec2 uv){
  uv =(uv * 2. -1.) * 2.;
  return max(
    abs(uv.x) * 0.866025 + uv.y * 0.5 ,
     -1. * uv.y * 0.5);
}

float rectSDF(vec2 uv, vec2 s){
  uv = uv * 2. -1.;
  return max(
     abs(uv.x/s.x),
     abs(uv.y/s.y));
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

float stroke(float x, float s, float w){
  float d = step(s,x + w * .5) -
  step(s, x-w *.5);
  return clamp(d, 0., 1.);
}
vec3 bridge(vec3 c, float d, float s, float w){
  c*= 1. -stroke(d,s,w*2.);
  return c + stroke(d,s,w);
}

float flip(float v, float pct){
  return mix(v, 1.-v, pct);
}

void main(){
  vec2 uv = (gl_FragCoord.xy - uResolution * .5) / uResolution.yy + 0.5;
  // vec2 uv = gl_FragCoord.xy / uResolution;
  // uv.x =flip(uv.x, step(.5, uv.y));
    float slowTime = vTime * .05;
    float alpha = 1.;
  // vec2 uv = vUv;
  vec3 color = vec3(.0);
  vec3 c1 = vec3(1., 1., 0.); // yellow
  vec3 c2 = vec3(1., 0., 0.); // yellow
  vec3 c3 = vec3(.5, 0.25, .91 * sin(vTime)); // yellow

  vec2 offset = vec2(.05, .05);
  vec2 rote = rotateUV(uv, vec2(.475), PI * slowTime);
  vec2 roteC = rotateUV(uv, vec2(.475), -PI * slowTime);
  float tri = triangleDF(rote + offset);
  float tri2 = triangleDF(roteC - offset);
  float tri3 = triangleDF(roteC - offset);

  float squareO = rectSDF(roteC, vec2(1.));
  color *= stroke(squareO, .4 * tan(vTime) * 0.8, .075* sin(vTime));

  vec3 square = shape(rote);
  square += mix(c1,c3, tri);
  color *= stroke(tri, .4, .075);
  color += stroke(tri3, .3, .075);
  color += stroke(tri3, .4, .075);
  color = bridge(color, tri2, .2, .75);
  color *= mix(c2,c3, square);
  color+= square;
    color.r += cnoise(rote * 40.0   );
    pModPolar(rote, 8. *sin(slowTime));
    color *= bridge(vec3(cnoise(rote * 40.0   )), color.g, .4, .075);
    color.g += cnoise(rote * 400.0   );
    color *= bridge(vec3(cnoise(roteC * 400.0   )), color.b, .2, .75);
    color.b += cnoise(roteC * 400.0   );
    color*= smoothstep(.005,.2 * sin(vTime),1.-tri2);

    if(color == vec3(0.,0.,0.)){
        color.b += cnoise(roteC * 40.0   );
        color.r += smoothstep(.005,.5 * sin(vTime),cnoise(rote * 40.0   ));
        color *= bridge(vec3(cnoise(roteC * 400.0   )), color.b, .2, .75);


        color += stroke(tri3, .4, .075);
        color = bridge(color, tri2, .2, .75);
        color *= mix(c2,c3, square);
        color*= square;
          color.r += cnoise(rote * 40.0   );
          color *= bridge(vec3(cnoise(rote * 40.0   )), color.g, .4, .075);


    }

 gl_FragColor =  vec4(color, alpha);

}
