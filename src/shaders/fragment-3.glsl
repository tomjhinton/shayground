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

float rand(float n){return fract(sin(n) * 43758.5453123);}



float hash(float n) { return fract(sin(n) * 1e4); }

float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float noise(float x) {
	float i = floor(x);
	float f = fract(x);
	float u = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), u);
}

float noise(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	// Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main(){
  vec2 uv = (gl_FragCoord.xy - uResolution * .5) / uResolution.yy + 0.5;
  vec3 color = vec3(0.);

  float n = 12.;

  // n*= rand(vTime);

  // float gridX = fract(uv.x * n);
  // float gridY = fract(uv.y * n);
  float halfTime = vTime * 0.00005;

  vec3 c1 = vec3(1. , 1. , 0.); //yelllow
  vec3 c2 = vec3(.5, 0., .5); // purple

  float test = noise(uv * 1.35);
  float gridX = mod(test * n + sin(vTime), 1.0);
  float gridY = mod(test * n * .5 + cos(vTime), 1.0);


  // color = vec3(gridX, gridY, uv.x);

  float noise = noise(vec2(gridX * sin(vTime), gridY * cos(vTime) + 1.75)) ;
  noise = smoothstep(2., .5, noise);
  color = vec3(vec2(noise), 3.1  / (uv.x + uv.y));
  // color = vec3(rand(color.y * vTime)) *  vec3(rand(color.x * vTime));
  color *= mix(c2, c1, 1.- uv.y);

  float grid = fract(uv.x);

 gl_FragColor = vec4(color, 1.);

}
