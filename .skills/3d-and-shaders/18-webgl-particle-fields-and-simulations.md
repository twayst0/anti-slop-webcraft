# Skill 18: High-Density GPU Particle Fields & Curl Noise Simulations

## 1. System Invariants

1. Pure GPU Vertex Animation:
   - Compute particle positions strictly inside WebGL vertex shaders using procedural noise functions.
   - NEVER loop through thousands of particle position coordinates on the CPU inside JavaScript animation ticks.
2. Geometry & Draw Call Economy:
   - Standardize on a single `THREE.Points` instance with `BufferGeometry` containing packed Float32Arrays (`a_position`, `a_randomness`).
   - Draw call budget: Exactly 1 draw call for up to 100,000 particles.
3. Pointer Gravitational Field:
   - Pass normalized 3D unprojected raycast pointer coordinates as a uniform (`u_pointer`) with an interactive radius and spring return velocity.

## 2. Production Implementation

### High-Density WebGL Particle Field (`GpuParticleField.tsx`)

```tsx
import React, { useEffect, useRef } from "react";
import * as THREE from "three";

const PARTICLE_VERTEX_SHADER = /* glsl */ `
  uniform float u_time;
  uniform vec3 u_pointer;
  attribute vec3 a_randomness;
  varying vec3 vColor;

  // 3D Simplex-style noise approximation
  vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
  vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

  float snoise(vec3 v){
    const vec2  C = vec2(1.0/6.0, 1.0/3.0);
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);
    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);
    vec3 x1 = x0 - i1 + 1.0 * C.xxx;
    vec3 x2 = x0 - i2 + 2.0 * C.xxx;
    vec3 x3 = x0 - 1.0 + 3.0 * C.xxx;
    i = mod(i, 289.0);
    vec4 p = permute(permute(permute(
              i.z + vec4(0.0, i1.z, i2.z, 1.0))
            + i.y + vec4(0.0, i1.y, i2.y, 1.0))
            + i.x + vec4(0.0, i1.x, i2.x, 1.0));
    vec4 j = p - 49.0 * floor(p * (1.0 / 49.0));
    vec4 x_ = floor(j * 0.142857);
    vec4 y_ = floor(j - 7.0 * x_);
    vec4 x = x_ * (2.0 / 7.0) + 0.5 / 7.0 - 1.0;
    vec4 y = y_ * (2.0 / 7.0) + 0.5 / 7.0 - 1.0;
    vec4 h = 1.0 - abs(x) - abs(y);
    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);
    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;
    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3)));
  }

  void main() {
    vec3 pos = position;
    float t = u_time * 0.1;

    // Curl noise displacement simulation
    float noiseX = snoise(pos * 0.5 + vec3(t, 0.0, 0.0));
    float noiseY = snoise(pos * 0.5 + vec3(0.0, t, 0.0));
    float noiseZ = snoise(pos * 0.5 + vec3(0.0, 0.0, t));
    pos += vec3(noiseX, noiseY, noiseZ) * 0.8;

    // Interactive pointer repulsion
    float distToPointer = distance(pos, u_pointer);
    if (distToPointer < 2.0) {
      vec3 dir = normalize(pos - u_pointer);
      pos += dir * (2.0 - distToPointer) * 0.5;
    }

    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
    gl_PointSize = (18.0 * a_randomness.x) * (1.0 / -mvPosition.z);
    gl_Position = projectionMatrix * mvPosition;

    // Calibrated color spectrum: deep ground to solar amber highlight
    vColor = mix(vec3(0.18, 0.22, 0.32), vec3(0.85, 0.45, 0.15), a_randomness.y);
  }
`;

const PARTICLE_FRAGMENT_SHADER = /* glsl */ `
  varying vec3 vColor;
  void main() {
    // Perfect circular particle point with soft radial edge
    float d = distance(gl_PointCoord, vec2(0.5));
    if (d > 0.5) discard;
    float alpha = smoothstep(0.5, 0.1, d);
    gl_FragColor = vec4(vColor, alpha * 0.7);
  }
`;

export const GpuParticleField: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null!);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const count = 40000;
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(50, container.clientWidth / container.clientHeight, 0.1, 100);
    camera.position.z = 6;

    const renderer = new THREE.WebGLRenderer({ antialias: false, alpha: true, powerPreference: "high-performance" });
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    container.appendChild(renderer.domElement);

    const positions = new Float32Array(count * 3);
    const randomness = new Float32Array(count * 3);

    for (let i = 0; i < count; i++) {
      const i3 = i * 3;
      positions[i3] = (Math.random() - 0.5) * 8;
      positions[i3 + 1] = (Math.random() - 0.5) * 6;
      positions[i3 + 2] = (Math.random() - 0.5) * 4;

      randomness[i3] = Math.random();
      randomness[i3 + 1] = Math.random();
      randomness[i3 + 2] = Math.random();
    }

    const geometry = new THREE.BufferGeometry();
    geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3));
    geometry.setAttribute("a_randomness", new THREE.BufferAttribute(randomness, 3));

    const uniforms = {
      u_time: { value: 0 },
      u_pointer: { value: new THREE.Vector3(100, 100, 0) },
    };

    const material = new THREE.ShaderMaterial({
      vertexShader: PARTICLE_VERTEX_SHADER,
      fragmentShader: PARTICLE_FRAGMENT_SHADER,
      uniforms,
      transparent: true,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    });

    const particles = new THREE.Points(geometry, material);
    scene.add(particles);

    let rafId: number;
    const clock = new THREE.Clock();

    const handlePointerMove = (e: MouseEvent) => {
      const rect = container.getBoundingClientRect();
      const x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
      const y = -(((e.clientY - rect.top) / rect.height) * 2 - 1);
      uniforms.u_pointer.value.set(x * 3.5, y * 2.5, 0);
    };

    window.addEventListener("pointermove", handlePointerMove);

    const render = () => {
      uniforms.u_time.value = clock.getElapsedTime();
      renderer.render(scene, camera);
      rafId = requestAnimationFrame(render);
    };
    render();

    return () => {
      cancelAnimationFrame(rafId);
      window.removeEventListener("pointermove", handlePointerMove);
      renderer.dispose();
      geometry.dispose();
      material.dispose();
      if (renderer.domElement.parentElement) {
        renderer.domElement.parentElement.removeChild(renderer.domElement);
      }
    };
  }, []);

  return <div ref={containerRef} className="absolute inset-0 h-full w-full pointer-events-none" />;
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Iterating over particle arrays in JavaScript `forEach` or `for` loops on CPU during `requestAnimationFrame`.
- Prohibited: Creating separate Three.js Mesh instances for each individual particle.
- Prohibited: Unbounded pointer repulsion that throws particles entirely out of camera frustum bounds without recovery.
- Prohibited: Omission of `depthWrite: false`, resulting in black particle alpha clipping boxes.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-PRT-001 (Ubiquitous): The particle simulation SHALL execute 40,000+ particles using a single draw call with GPU-side vertex displacement.
- REQ-PRT-002 (Ubiquitous): Particle points SHALL implement soft radial circular masking via fragment shader discard operations.
- REQ-PRT-003 (State-Driven): WHILE pointer moves through the particle field, particles within proximity SHALL divert and return via fluid curl noise.
- REQ-PRT-004 (Unwanted Behavior): IF the WebGL context is lost, THEN the renderer SHALL handle context recovery gracefully without unhandled exceptions.
