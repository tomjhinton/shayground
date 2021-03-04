const float PI = 3.1415926535897932384626433832795;

uniform vec2 uMouse;
uniform float uTime;
varying float vTime;
varying vec2 vUv;
uniform vec2 uFrequency;
uniform vec3 uPosition;
uniform vec3 uRotation;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
  mat2 rotation_matrix=mat2(  vec2(sin(rotation),-cos(rotation)),
                              vec2(cos(rotation),sin(rotation))
                              );
  uv -= pivot;
  uv= uv*rotation_matrix;
  uv += pivot;
  return uv;
}



void main()

{

  vec4 modelPosition = modelMatrix * vec4(position, 1.0);

  modelPosition.y *= rotateUV(modelPosition.xy, vec2(.5), PI * (uTime * .5)).y + modelPosition.z;

vec4 viewPosition = viewMatrix * modelPosition;

vec4 projectedPosition = projectionMatrix * viewPosition;

gl_Position = projectedPosition;

  // gl_Position = vec4(position, 1.0);
  //

  vUv = uv;
  vTime = uTime;

}



// uniform vec2 uMouse;
// uniform float uTime;
// varying float vTime;
// varying vec2 vUv;
// uniform vec2 uFrequency;
// uniform vec3 uPosition;
// uniform vec3 uRotation;
//
// #define M_PI 3.14159265
// uniform float wrapAmountUniform;
//
// vec3 anglesToSphereCoord(vec2 a, float r)
// {
//     return vec3(
//     	r * sin(a.y) * sin(a.x),
//       r * cos(a.y),
//       r * sin(a.y) * cos(a.x)
//     );
// }
//
// void main()	{
// 	vec2 angles = M_PI * vec2(2. * uv.x, uv.y - 1.);
//   vec3 sphPos = anglesToSphereCoord(angles, 0.6);
//   vec3 wrapPos = mix(position, sphPos, ((sin(uTime)+1.)/2.));
//
//   gl_Position = projectionMatrix * modelViewMatrix * vec4( wrapPos, 1.0 );
//
//   vUv = uv;
//   vTime = uTime;
// }
