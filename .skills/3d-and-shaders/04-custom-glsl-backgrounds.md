# Skill 04: Custom GLSL Shaders, Procedural Noise & Grain Passes

## 1. System Invariants

1. Fullscreen Quad Architecture:
   - Execute background visual fields via single-pass WebGL fullscreen quad (`PlaneGeometry(2, 2)`) with custom fragment shaders.
   - Always pass normalized uniforms: `u_time` (float in seconds), `u_resolution` (vec2 in device pixels), `u_mouse` (vec2 dampened screen coordinates).
2. Procedural Noise Physics:
   - Use analytical Simplex or Perlin noise implementations directly within GLSL. Avoid uploading pre-baked texture noise maps where procedural math is more cache-efficient.
   - Inject filmic post-pass grain: Calculate pseudo-random grain (`fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453)`) with a calibrated opacity threshold (`0.035 - 0.055`).
3. Frame Budget & Precision:
   - Declare `precision highp float;` for desktop devices and gracefully degrade to `mediump` on mobile GPUs if required.
   - Maintain execution cost under 4.0ms per frame at 1080p resolution.

## 2. Production Implementation

### Complete Raw GLSL Shader & React Canvas Harness (`GlslBackground.tsx`)

```tsx
import React, { useEffect, useRef } from "react";
import * as THREE from "three";

const VERTEX_SHADER = /* glsl */ `
  varying vec2 vUv;
  void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
  }
`;

const FRAGMENT_SHADER = /* glsl */ `
  uniform float u_time;
  uniform vec2 u_resolution;
  uniform vec2 u_mouse;
  varying vec2 vUv;

  // 2D Simplex Noise Primitive
  vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

  float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
             -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
      + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
      dot(x12.zw,x12.zw)), 0.0);
    m = m*m;
    m = m*m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
  }

  void main() {
    vec2 st = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / min(u_resolution.y, u_resolution.x);
    vec2 mouse = (u_mouse - 0.5) * 0.5;

    // Distorted multi-octave coordinate field
    float t = u_time * 0.15;
    float n1 = snoise(st * 2.0 + vec2(t * 0.5, -t * 0.3) + mouse);
    float n2 = snoise(st * 4.0 - vec2(-t * 0.2, t * 0.4) + vec2(n1 * 0.5));

    // Deep OKLCH-aligned palette synthesis
    vec3 baseColor = vec3(0.04, 0.05, 0.07); // Neutral ground
    vec3 accentColor = vec3(0.85, 0.45, 0.15); // Solar Amber spectrum
    vec3 fieldColor = mix(baseColor, accentColor, smoothstep(0.1, 0.8, n2 * 0.5 + 0.5) * 0.35);

    // Dynamic Micro-Grid Overlay
    vec2 gridUv = fract(st * 40.0);
    float grid = step(0.97, gridUv.x) + step(0.97, gridUv.y);
    fieldColor += vec3(grid * 0.02);

    // Filmic Grain Synthesis
    float grain = fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453);
    fieldColor += (grain - 0.5) * 0.04;

    gl_FragColor = vec4(fieldColor, 1.0);
  }
`;

export const ProceduralShaderCanvas: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null!);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const scene = new THREE.Scene();
    const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
    const renderer = new THREE.WebGLRenderer({ antialias: false, powerPreference: "high-performance" });
    
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    container.appendChild(renderer.domElement);

    const uniforms = {
      u_time: { value: 0 },
      u_resolution: { value: new THREE.Vector2(container.clientWidth, container.clientHeight) },
      u_mouse: { value: new THREE.Vector2(0.5, 0.5) },
    };

    const geometry = new THREE.PlaneGeometry(2, 2);
    const material = new THREE.ShaderMaterial({
      vertexShader: VERTEX_SHADER,
      fragmentShader: FRAGMENT_SHADER,
      uniforms,
      depthWrite: false,
      depthTest: false,
    });

    const quad = new THREE.Mesh(geometry, material);
    scene.add(quad);

    let animationFrameId: number;
    const clock = new THREE.Clock();

    const handlePointerMove = (e: MouseEvent) => {
      const rect = container.getBoundingClientRect();
      uniforms.u_mouse.value.set(
        (e.clientX - rect.left) / rect.width,
        1.0 - (e.clientY - rect.top) / rect.height
      );
    };

    const handleResize = () => {
      const width = container.clientWidth;
      const height = container.clientHeight;
      renderer.setSize(width, height);
      uniforms.u_resolution.value.set(width, height);
    };

    window.addEventListener("resize", handleResize);
    window.addEventListener("pointermove", handlePointerMove);

    const render = () => {
      uniforms.u_time.value = clock.getElapsedTime();
      renderer.render(scene, camera);
      animationFrameId = requestAnimationFrame(render);
    };
    render();

    return () => {
      cancelAnimationFrame(animationFrameId);
      window.removeEventListener("resize", handleResize);
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

- Prohibited: Generic CSS linear gradients or multiple stacked `radial-gradient` divs masquerading as interactive backgrounds.
- Prohibited: Executing procedural noise generation on the CPU using 2D canvas `getImageData()` or `putImageData()`.
- Prohibited: Forgetting window resize listener cleanup or causing WebGL context leaks via un-disposed geometries and materials.
- Prohibited: Unbounded `u_time` variables without modulo wrapping in long-running sessions, causing float precision breakdown.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-GLSL-001 (Ubiquitous): The shader pipeline SHALL maintain a continuous GPU frametime under 5.0ms on standard integrated graphics.
- REQ-GLSL-002 (Ubiquitous): The shader uniforms SHALL update mouse coordinates with continuous bilinear interpolation to avoid stepping artifacts.
- REQ-GLSL-003 (State-Driven): WHILE window resizing occurs, the fragment shader SHALL recalibrate `u_resolution` within a single animation frame without aspect ratio distortion.
- REQ-GLSL-004 (Unwanted Behavior): IF the component unmounts, THEN all Three.js geometries, materials, listeners, and renderers SHALL be fully disposed of to prevent memory leaks.
