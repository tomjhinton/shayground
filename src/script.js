import './style.css'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'

let webcamTexture, video;
function initWebcamCapture(){
    video = document.createElement('video');
    video.autoplay="";
    video.style="display:none";
    video.id="feedCam";
     console.log(video)
    if ( navigator.mediaDevices && navigator.mediaDevices.getUserMedia && video) {
        var constraints = { video: { width: 1280, height: 720, facingMode: 'user' } };


        navigator.mediaDevices.getUserMedia( constraints ).then( function ( stream ) {
            video.srcObject = stream;
            video.play();
        } ).catch( function ( error ) {
            console.error( 'Unable to access the camera/webcam.', error );

        } );

    } else {
        console.error( 'MediaDevices interface not available.' );
    }
    window.video = document.getElementById('video');

    webcamTexture = new THREE.VideoTexture(video);
    webcamTexture.minFilter = THREE.LinearFilter;
    webcamTexture.magFilter = THREE.LinearFilter;
    webcamTexture.needsUpdate= true;
}
initWebcamCapture();


import vertexShader1 from './shaders/vertex.glsl'
import fragmentShader1 from './shaders/fragment-88.glsl'

 // * Base
 // */
// Debug


console.log(navigator)

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()
scene.background = new THREE.Color( 0xffffff )

/**
 * Textures
 */
const textureLoader = new THREE.TextureLoader()
const texture = textureLoader.load('./textures/texture.JPG')

/**
 * Test mesh
 */

//geometry
// const geometry =  new THREE.SphereGeometry( 2, 320, 320, 160 )
const geometry =  new THREE.PlaneGeometry( 2, 2, 128, 128)
// const geometry = new THREE.BoxGeometry(1,1,1, 128, 128, 128)





// Material
const material = new THREE.ShaderMaterial({
  vertexShader: vertexShader1,
  fragmentShader: fragmentShader1,
  transparent: true,
  depthWrite: true,
  clipShadows: true,
  wireframe: false,
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
    uVideo: {
      value: webcamTexture
    },
    uVideo2: {
      value: webcamTexture
    },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    },
    uResolution: { type: 'v2', value: new THREE.Vector2() },
    uPosition: {
      value: {
        x: 0
      }
    },
    uRotation: {
      value: 0



    }
  }
})
console.log(material)

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
camera.position.set(0,0,1.5)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
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

  // mesh.rotation.y +=0.005
  // mesh.rotation.x +=0.005
  // Update controls

  // mesh.position.copy(camera.position)


  // Render
  renderer.render(scene, camera)



  // Call tick again on the next frame
  window.requestAnimationFrame(tick)
}

tick()
