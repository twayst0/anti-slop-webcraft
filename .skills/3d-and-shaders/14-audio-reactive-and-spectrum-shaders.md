# Skill 14: Audio-Reactive Shaders & Web Audio FFT Spectrum Transduction

## 1. System Invariants

1. Audio Pipeline Architecture:
   - Extract real-time frequency data using standard `AudioContext` and `AnalyserNode` (`fftSize: 256` or `512`).
   - Smooth raw frequency spectrum buffers using an exponential moving average (`smooth = prev * 0.85 + current * 0.15`) before passing to GLSL uniforms.
2. Uniform Normalization & Range Mapping:
   - Normalize audio frequency spectrum:
     - `u_bass`: Low frequencies (20-150Hz), normalized [0.0, 1.0], drives structural mesh displacement.
     - `u_treble`: High frequencies (2kHz-16kHz), drives chromatic aberration and filmic grain intensity.
3. User Gesture & Audio Permission Protocol:
   - Comply strictly with browser autoplay policies: `AudioContext` MUST remain suspended until initiated by an explicit user gesture (`pointerdown` or `click`).

## 2. Production Implementation

### Audio Reactive Sphere Shader (`AudioReactiveSphere.tsx`)

```tsx
import React, { useEffect, useRef, useState } from "react";
import * as THREE from "three";
import { SpeakerHigh, Play, Pause } from "@phosphor-icons/react";

const AUDIO_VERTEX_SHADER = /* glsl */ `
  uniform float u_time;
  uniform float u_bass;
  varying vec3 vNormal;
  varying vec2 vUv;

  void main() {
    vNormal = normal;
    vUv = uv;

    // Displacement modulation via bass frequency
    vec3 pos = position;
    float displacement = sin(pos.x * 4.0 + u_time * 2.0) * cos(pos.y * 4.0 + u_time * 2.0) * (u_bass * 0.4);
    pos += normal * displacement;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
  }
`;

const AUDIO_FRAGMENT_SHADER = /* glsl */ `
  uniform float u_time;
  uniform float u_treble;
  varying vec3 vNormal;
  varying vec2 vUv;

  void main() {
    vec3 normal = normalize(vNormal);
    float fresnel = pow(1.0 - abs(dot(normal, vec3(0.0, 0.0, 1.0))), 3.0);

    // Deep OKLCH-aligned base with reactive high-frequency pulse
    vec3 baseColor = vec3(0.05, 0.06, 0.09);
    vec3 accentColor = vec3(0.85, 0.45, 0.15); // Solar Amber
    vec3 trebleColor = vec3(0.2, 0.8, 0.6);   // Emerald edge

    vec3 finalColor = mix(baseColor, accentColor, fresnel + (u_treble * 0.3));
    finalColor += trebleColor * pow(fresnel, 2.0) * (u_treble * 0.5);

    gl_FragColor = vec4(finalColor, 1.0);
  }
`;

export const AudioReactiveScene: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null!);
  const [isPlaying, setIsPlaying] = useState(false);
  const audioCtxRef = useRef<AudioContext | null>(null);
  const analyserRef = useRef<AnalyserNode | null>(null);
  const uniformsRef = useRef({
    u_time: { value: 0 },
    u_bass: { value: 0 },
    u_treble: { value: 0 },
  });

  const toggleAudio = async () => {
    if (!audioCtxRef.current) {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      const ctx = new AudioCtx();
      const analyser = ctx.createAnalyser();
      analyser.fftSize = 256;

      // Synthesize ambient oscillator signal for zero-asset demonstration
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sine";
      osc.frequency.setValueAtTime(65, ctx.currentTime);
      gain.gain.setValueAtTime(0.15, ctx.currentTime);

      osc.connect(gain);
      gain.connect(analyser);
      analyser.connect(ctx.destination);
      osc.start();

      audioCtxRef.current = ctx;
      analyserRef.current = analyser;
      setIsPlaying(true);
    } else if (audioCtxRef.current.state === "suspended") {
      await audioCtxRef.current.resume();
      setIsPlaying(true);
    } else {
      await audioCtxRef.current.suspend();
      setIsPlaying(false);
    }
  };

  useEffect(() => {
    const container = containerRef.current;
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 100);
    camera.position.z = 4;

    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    container.appendChild(renderer.domElement);

    const geometry = new THREE.IcosahedronGeometry(1.2, 64);
    const material = new THREE.ShaderMaterial({
      vertexShader: AUDIO_VERTEX_SHADER,
      fragmentShader: AUDIO_FRAGMENT_SHADER,
      uniforms: uniformsRef.current,
      wireframe: false,
    });

    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    let rafId: number;
    const clock = new THREE.Clock();
    const dataArray = new Uint8Array(128);

    const render = () => {
      const delta = clock.getDelta();
      uniformsRef.current.u_time.value = clock.getElapsedTime();
      mesh.rotation.y += delta * 0.2;

      if (analyserRef.current && isPlaying) {
        analyserRef.current.getByteFrequencyData(dataArray);
        // Extract bass (low bins) and treble (high bins)
        const bassAvg = (dataArray[2] + dataArray[3] + dataArray[4]) / (3 * 255);
        const trebleAvg = (dataArray[60] + dataArray[61] + dataArray[62]) / (3 * 255);

        uniformsRef.current.u_bass.value += (bassAvg - uniformsRef.current.u_bass.value) * 0.15;
        uniformsRef.current.u_treble.value += (trebleAvg - uniformsRef.current.u_treble.value) * 0.15;
      } else {
        uniformsRef.current.u_bass.value *= 0.95;
        uniformsRef.current.u_treble.value *= 0.95;
      }

      renderer.render(scene, camera);
      rafId = requestAnimationFrame(render);
    };
    render();

    return () => {
      cancelAnimationFrame(rafId);
      renderer.dispose();
      geometry.dispose();
      material.dispose();
      if (renderer.domElement.parentElement) {
        renderer.domElement.parentElement.removeChild(renderer.domElement);
      }
    };
  }, [isPlaying]);

  return (
    <div className="relative h-[480px] w-full overflow-hidden rounded-2xl border border-[oklch(1_0_0_/_0.08)] bg-[oklch(0.12_0.015_250)]">
      <div ref={containerRef} className="h-full w-full" />
      <div className="absolute bottom-6 left-6 z-10">
        <button
          onClick={toggleAudio}
          className="flex items-center gap-2 rounded-xl border border-[oklch(0.85_0.18_85_/_0.3)] bg-[oklch(0.85_0.18_85_/_0.1)] px-4 py-2 font-mono text-xs uppercase tracking-wider text-[oklch(0.85_0.18_85)] backdrop-blur-md transition-colors hover:bg-[oklch(0.85_0.18_85_/_0.2)]"
        >
          {isPlaying ? <Pause size={14} weight="bold" /> : <Play size={14} weight="bold" />}
          <span>{isPlaying ? "SUSPEND_AUDIO_STREAM" : "INITIALIZE_FFT_AUDIO"}</span>
        </button>
      </div>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Creating `AudioContext` instances on initial script execution without waiting for user action.
- Prohibited: Passing raw unsmoothed FFT arrays into uniforms, which produces harsh visual strobing.
- Prohibited: Allocating new TypedArrays inside the 60 FPS animation loop.
- Prohibited: Failing to suspend `AudioContext` on page backgrounding, exhausting system audio hardware channels.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-AUD-001 (Ubiquitous): Audio frequency sampling SHALL execute through an `AnalyserNode` with normalized uniform values bounded within [0.0, 1.0].
- REQ-AUD-002 (Ubiquitous): Audio data buffering SHALL reuse a pre-allocated Uint8Array to achieve zero heap allocations per frame.
- REQ-AUD-003 (State-Driven): WHILE user audio playback is inactive, shader deformation uniforms SHALL decay gracefully to zero within 300ms.
- REQ-AUD-004 (Unwanted Behavior): IF the browser blocks audio autoplay, THEN the WebGL scene SHALL maintain ambient mathematical rotation without throwing errors.
