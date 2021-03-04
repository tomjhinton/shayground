import './style.css'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'




import vertexShader1 from './shaders/vertex-noise.glsl'
import fragmentShader1 from './shaders/fragment-6.glsl'


/**
 * Base
 */
// Debug




// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()
scene.background = new THREE.Color( 0xffffff );

/**
 * Textures
 */
const textureLoader = new THREE.TextureLoader()
const texture = textureLoader.load('./textures/texture.png')

/**
 * Test mesh
 */

//geometry
const geometry =  new THREE.SphereGeometry( .51, 320, 320, 320 )



// Material
const material = new THREE.ShaderMaterial({
  vertexShader: vertexShader1,
  fragmentShader: fragmentShader1,
  transparent: true,
  depthWrite: true,
  clipShadows: true,
  side: THREE.DoubleSide,
  uniforms: {
    uFrequency: {
      value: new THREE.Vector2(10, 5)
    },
    uTime: {
      value: 0
    },
    uColor: {
      value: new THREE.Color('orange')
    },
    uTexture: {
      value: texture
    },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    },
    uResolution: { type: "v2", value: new THREE.Vector2() },
    uPosition: {
      value: {
        x: 0
      }
    },
    uRotation: {
      value: {

      }
    }
  }
})


const mesh = new THREE.Mesh(geometry, material)
scene.add(mesh)


window.addEventListener('mousemove', function (e) {
  material.uniforms.uMouse.value.x =  (e.clientX / window.innerWidth) * 2 - 1
  material.uniforms.uMouse.value.y = -(event.clientY / window.innerHeight) * 2 + 1

})




/**
 * Sizes
 */
const sizes = {
  width: window.innerWidth,
  height: window.innerHeight
}

window.addEventListener('resize', () =>{

  //Update uniforms



  material.uniforms.uResolution.value.x = renderer.domElement.width
  material.uniforms.uResolution.value.y = renderer.domElement.height

  // Update sizes
  sizes.width = window.innerWidth
  sizes.height = window.innerHeight

  // Update camera
  camera.aspect = sizes.width / sizes.height
  camera.updateProjectionMatrix()

  // Update renderer
  renderer.setSize(sizes.width, sizes.height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
camera.position.set(0,0,4.5)
scene.add(camera)

// Controls
// const controls = new OrbitControls(camera, canvas)
// controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
  canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
renderer.localClippingEnabled = true
renderer.globalClippingEnabled = true

/**
 * Animate
 */

console.log(mesh)

const clock = new THREE.Clock()

const tick = () =>{
  const elapsedTime = clock.getElapsedTime()
  if(material.uniforms.uResolution.value.x === 0 && material.uniforms.uResolution.value.y === 0 ){
    material.uniforms.uResolution.value.x = renderer.domElement.width
    material.uniforms.uResolution.value.y = renderer.domElement.height
  }
  // console.log(camera)
  //Update Material
  material.uniforms.uTime.value = elapsedTime
  material.uniforms.uPosition.value = mesh.position
  material.uniforms.uRotation.value = mesh.rotation
  // console.log(material.uniforms)

  mesh.rotation.y +=0.001
  mesh.rotation.x +=0.001
  // Update controls

  // mesh.position.copy(camera.position)


  // Render
  renderer.render(scene, camera)



  // Call tick again on the next frame
  window.requestAnimationFrame(tick)
}

tick()
