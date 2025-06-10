import { useEffect, useRef } from 'react';
import * as THREE from 'three';

function WhyTravelitin() {
  const canvasContainerRef = useRef(null);
  const textRef = useRef(null);
  const globeRef = useRef(null);

  useEffect(() => {
    const width = canvasContainerRef.current.offsetWidth;
    const height = canvasContainerRef.current.offsetHeight;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 10000);
    camera.position.z = 2.5;

    const renderer = new THREE.WebGLRenderer({ alpha: true });
    renderer.setSize(width, height);
    renderer.setPixelRatio(window.devicePixelRatio);
    canvasContainerRef.current.appendChild(renderer.domElement);

    // Resize handler
    const handleResize = () => {
      const width = canvasContainerRef.current.offsetWidth;
      const height = canvasContainerRef.current.offsetHeight;
      renderer.setSize(width, height);
      camera.aspect = width / height;
      camera.updateProjectionMatrix();
    };
    window.addEventListener('resize', handleResize);

    // Globe
    const textureLoader = new THREE.TextureLoader();
    const texture = textureLoader.load('https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_atmos_2048.jpg');
    const bumpMap = textureLoader.load('https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_bump_2048.jpg');
    const specularMap = textureLoader.load('https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_specular_2048.jpg');

    const globe = new THREE.Mesh(
      new THREE.SphereGeometry(1, 64, 64),
      new THREE.MeshPhongMaterial({
        map: texture,
        bumpMap: bumpMap,
        bumpScale: 0.05,
        specularMap: specularMap,
        specular: new THREE.Color(0x66ccff),
        shininess: 50,
      })
    );
    globeRef.current = globe;
    scene.add(globe);

    // Atmosphere glow
    const atmosphere = new THREE.Mesh(
      new THREE.SphereGeometry(1.05, 64, 64),
      new THREE.ShaderMaterial({
        vertexShader: `
          varying vec3 vNormal;
          void main() {
            vNormal = normalize(normalMatrix * normal);
            gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
          }
        `,
        fragmentShader: `
          varying vec3 vNormal;
          void main() {
            float intensity = pow(0.8 - dot(vNormal, vec3(0, 0, 1.0)), 2.0);
            gl_FragColor = vec4(0.3, 0.8, 0.6, 1.0) * intensity;
          }
        `,
        side: THREE.BackSide,
        blending: THREE.AdditiveBlending,
        transparent: true,
      })
    );
    scene.add(atmosphere);

    // Stars
    const starGeometry = new THREE.BufferGeometry();
    const starCount = 10000;
    const starPositions = new Float32Array(starCount * 3);
    for (let i = 0; i < starCount * 3; i++) {
      starPositions[i] = (Math.random() - 0.5) * 6000;
    }
    starGeometry.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));

    const starMaterial = new THREE.PointsMaterial({
      color: 0xffffff,
      size: 1.2,
      transparent: true,
      opacity: 0.8,
    });
    const stars = new THREE.Points(starGeometry, starMaterial);
    scene.add(stars);

    // Lights
    scene.add(new THREE.AmbientLight(0xffffff, 0.5));
    const light1 = new THREE.DirectionalLight(0xffffff, 0.5);
    light1.position.set(-3, -2, 1);
    scene.add(light1);

    const light2 = new THREE.DirectionalLight(0xffffff, 1);
    light2.position.set(5, 3, 5);
    scene.add(light2);

    // Animate
    const animate = () => {
      requestAnimationFrame(animate);
      globe.rotation.y += 0.004;
      atmosphere.rotation.y = globe.rotation.y;
      stars.rotation.y += 0.0002;
      stars.rotation.x += 0.0001;
      starMaterial.opacity = 0.7 + 0.3 * Math.sin(Date.now() * 0.001);
      renderer.render(scene, camera);
    };
    animate();

    return () => {
      window.removeEventListener('resize', handleResize);
      canvasContainerRef.current.removeChild(renderer.domElement);
    };
  }, []);

  return (
    <section className="relative bg-black text-white py-16 min-h-screen overflow-hidden">
      {/* Canvas Background */}
      <div
        ref={canvasContainerRef}
        className="absolute inset-0 z-0"
      />

      {/* Content */}
      <div className="relative z-10 max-w-5xl mx-auto px-4 flex flex-col md:flex-row items-start gap-10">
        <div ref={textRef} className="flex-1 text-center md:text-left">
          <h2 className="text-3xl md:text-4xl font-semibold mb-4 animate-fade-in">Best Choice</h2>
          <h3 className="text-2xl md:text-3xl font-semibold mb-8 animate-fade-in">Why Travelitin?</h3>
          <p className="text-lg md:text-xl mb-6 animate-slide-in-up">
            “Because travel should be exciting—not stressful.”
          </p>
          <p className="text-lg md:text-xl animate-slide-in-up">
            Travelitin brings you everything you need in one smart, safety-first travel companion. Whether you're exploring a new city, navigating unfamiliar roads, or planning your next adventure, we’ve got your back — with features that truly matter.
          </p>
        </div>
        <div className="flex-1 flex justify-center items-center h-64">
          <div className="w-[300px] h-[300px]" />
        </div>
      </div>
    </section>
  );
}

export default WhyTravelitin;
