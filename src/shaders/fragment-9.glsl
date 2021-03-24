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

vec3 shape( in vec2 p )
{

  float d = 0.0;
  vec2 st = p *2.-1.;

  // Number of sides of your shape
  int N = 3 ;

  // Angle and radius from the current pixel
  float a = atan(st.x,st.y)+PI ;
  float r = (2.* PI)/float(N) ;

  // Shaping function that modulate the distance
  d = cos(floor(.5+a/r)*r-a)*length(st);


  return  vec3(1.0-smoothstep(.4,.41,d));
}

float triangleDF(vec2 uv){
  uv =(uv * 2. -1.) * 2.;
  return max(
    abs(uv.x) * 0.866025 + uv.y * 0.5,
     -1. * uv.y * 0.5);
}

float chevronDF(vec2 uv){
  uv =(uv * 2. -1.) * 2.;
  return max(
    abs(uv.x) + uv.y,
      uv.y);
}

float chevronMDF(vec2 uv){
  uv =(-uv * 2. -1.) * 2.;
  return min(
    abs(uv.x) - uv.y,
      uv.y);
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
  vec2 uv = (gl_FragCoord.xy - uResolution * .5) / uResolution.yy + 0.5;
  // vec2 uv = gl_FragCoord.xy / uResolution;
    float slowTime = vTime * .05;
    float alpha = 1.;
  // vec2 uv = vUv;
  vec3 color = vec3(1.);
  vec3 c1 = vec3(1., 1., 0.); // yellow
  vec3 c2 = vec3(1., 0., 10.); // yellow
  vec3 c3 = vec3(.5, 0.25, .91); // yellow


  color *= triangleDF(uv) * 2. - tan(vTime);
  color *= triangleDF(uv) * 2. - tan(2. + vTime);

  color *= triangleDF(uv) * 4. - tan(vTime);
  color *= triangleDF(uv) * 4. - tan(2. + vTime);

  float chevron = chevronDF(uv) * 4. - tan(vTime);
  float tri = triangleDF(uv) * 4. - tan(2. + vTime);

  color *= chevronDF(uv) * 4. - tan(2. + vTime);
  color *= chevronMDF(uv)  - tan(3. + vTime);


  color *= smoothstep(0.05, .25, color);

  color = mix(c1, c2, color);
  color += mix(c2* c3, c1, color);

  color = mix(
    vec3(chevron) ,
    color,
    vec3(tri)
    );

 gl_FragColor =  vec4(color, alpha);

}
