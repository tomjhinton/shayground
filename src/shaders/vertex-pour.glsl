const float PI = 3.1415926535897932384626433832795;

uniform vec2 uMouse;
uniform float uTime;
varying float vTime;
varying vec2 vUv;
uniform vec2 uFrequency;
uniform vec3 uPosition;
uniform vec3 uRotation;
uniform vec2 uResolution;


vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
  mat2 rotation_matrix=mat2(  vec2(sin(rotation),-cos(rotation)),
                              vec2(cos(rotation),sin(rotation))
                              );
  uv -= pivot;
  uv= uv*rotation_matrix;
  uv += pivot;
  return uv;
}

vec2 brownConradyDistortion(in vec2 uv, in float k1, in float k2)
{
    uv = uv * 2.0 - 1.0;	// brown conrady takes [-1:1]

    // positive values of K1 give barrel distortion, negative give pincushion
    float r2 = uv.x*uv.x + uv.y*uv.y;
    uv *= 1.0 + k1 * r2 + k2 * r2 * r2;

    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here

    uv = (uv * .5 + .5);	// restore -> [0:1]
    return uv;
}


void main()

{




  vec4 modelPosition = modelMatrix * vec4(position, 1.0);

  modelPosition.yz = brownConradyDistortion(modelPosition.yz, -2., 2. );


vec4 viewPosition = viewMatrix * modelPosition;

vec4 projectedPosition = projectionMatrix * viewPosition;

gl_Position = projectedPosition;
//


  // gl_Position = vec4(position, 1.0);
  // //

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
