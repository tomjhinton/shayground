

uniform vec2 uResolution;
uniform vec2 uMouse;
varying float vTime;

#define PI 3.14159265
#define TAU (2*PI)
#define PHI (sqrt(5)*0.5 + 0.5)

// https://math.stackexchange.com/questions/2491494/does-there-exist-a-smooth-approximation-of-x-bmod-y
// found this equation and converted it to GLSL, usually e is supposed to be squared but in this case I like the way it looks as 0 //idk
float smoothMod(float x, float y, float e){
float top = cos(PI * (x/y)) * sin(PI * (x/y));
float bot = pow(sin(PI * (x/(y+0.1))),2.)+ pow(e, sin(vTime));
float at = atan(top/bot);
return y * (1./2.) - (1./PI) * at ;
}


vec3 hsb2rgb( in vec3 c ){
vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                       6.0)-3.0)-1.0,
               0.0,
               1.0 );
rgb = rgb*rgb*(3.0-2.0*rgb);
return c.z * mix( vec3(1.0), rgb, c.y);
}

// to see this function graphed out go to: https://www.desmos.com/calculator/rz7abjujdj
vec3 cosPalette( float t )
{
vec2 normCoord = gl_FragCoord.xy/uResolution;
t = t * 0.15;
vec2 uv = -1. + 2. * normCoord;

// please play around with these numbers to get a better palette
vec3 brightness = vec3(.6, .43, .9);
vec3 contrast = vec3(length(uv)*.5, 0.2, .5);
vec3 osc = vec3(0.0,0.0,0.0);
vec3 phase = vec3(10.,122.0,6.);
return brightness + contrast*cos( 6.28318*(osc*t+phase) );
}

// main is a reserved function that is going to be called first
void main(void)
{
vec2 normCoord = gl_FragCoord.xy/uResolution;
float t = vTime;
t = t * 0.15;
vec2 uv = -1. + 2. * normCoord;
// Unfortunately our screens are not square so we must account for that.
uv.x *= (uResolution.x / uResolution.y);

float xSmoothMod = smoothMod(uv.x,0.3,0.2);

float ySmoothMod = smoothMod(uv.y,0.3,0.2);

float smoothMix = (sin(t - atan(uv.x/uv.y*tan(t+uv.y))*2.)+1.0)/2.0;

uv.x = mix(uv.x, xSmoothMod, smoothMix);
uv.y = mix(uv.y, ySmoothMod, 1.-smoothMix);

uv.x = uv.y+sin(uv.x*5.) * 1.0 + t;

uv.y = clamp(abs(uv.y), 0.65, 0.5);

vec3 co = cosPalette(fract((uv.x/uv.y+uv.x) * 0.25) + cos(t*1.5));
vec3 iri = hsb2rgb(vec3(co.x,co.y,co.y*0.6));

iri += sin(length(uv) * 10.0 + t);


gl_FragColor = vec4(mix(co,iri,sin(t + uv.x/uv.y)),1);

}






///////////////////////////////////////////////////////////////////////////////////////////////
