# Skill 03: React Three Fiber Physical Glass & Liquid Metal Materials

## 1. System Invariants

1. Optical Transmission Physics:
   - Always utilize `@react-three/drei` `MeshTransmissionMaterial` for translucent elements rather than generic `opacity` or standard `MeshPhysicalMaterial`.
   - Index of Refraction (IOR): Default to `1.52` (optical crown glass) or `1.45` (fused silica).
   - Chromatic Aberration: Calibrate between `0.04` and `0.08` to generate subtle spectral fringe without optical blurriness.
   - Distortion & Temporal Motion: Couple transmission distortion with subtle vertex displacement.
2. Performance & Buffer Management:
   - Dynamic Resolution: Set `resolution={256}` or `resolution={512}` based on device pixel ratio.
   - FPS Watchdog: Monitor render loop cadence via `useFrame`. If frame time consistently exceeds 22ms (< 45 FPS), downscale resolution to `128` and disable anisotropic samples.
3. Lighting & Environment Grounding:
   - Physical glass materials require an environment map (HDRI) or back-lit geometric emissives to resolve refraction correctly. Never render transmission materials in an unlit void.

## 2. Production Implementation

### Liquid Glass Slab Component (`LiquidGlassScene.tsx`)

```tsx
import React, { useRef } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import {
  MeshTransmissionMaterial,
  Environment,
  Float,
  Center,
} from "@react-three/drei";
import * as THREE from "three";

interface GlassArtifactProps {
  roughness?: number;
  chromaticAberration?: number;
  ior?: number;
}

const GlassArtifact: React.FC<GlassArtifactProps> = ({
  roughness = 0.12,
  chromaticAberration = 0.05,
  ior = 1.52,
}) => {
  const meshRef = useRef<THREE.Mesh>(null!);

  useFrame((state, delta) => {
    // Controlled subtle physical oscillation
    meshRef.current.rotation.x += delta * 0.15;
    meshRef.current.rotation.y += delta * 0.2;
  });

  return (
    <Float speed={2} rotationIntensity={0.5} floatIntensity={0.8}>
      <mesh ref={meshRef} castShadow receiveShadow>
        <torusKnotGeometry args={[1, 0.35, 128, 32]} />
        <MeshTransmissionMaterial
          backside={true}
          samples={16}
          resolution={512}
          transmission={0.98}
          roughness={roughness}
          ior={ior}
          chromaticAberration={chromaticAberration}
          anisotropy={0.2}
          distortion={0.3}
          distortionScale={0.5}
          temporalDistortion={0.1}
          color="#f4f8ff"
          attenuationDistance={0.5}
          attenuationColor="#ffffff"
        />
      </mesh>
    </Float>
  );
};

export const PhysicalGlassCanvas: React.FC = () => {
  return (
    <div className="relative h-[600px] w-full overflow-hidden rounded-2xl bg-[oklch(0.12_0.015_250)]">
      {/* Background Emissive Grid */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_center,oklch(0.85_0.18_85_/_0.08)_0%,transparent_70%)]" />

      <Canvas
        camera={{ position: [0, 0, 5], fov: 45 }}
        dpr={[1, 2]}
        gl={{
          antialias: true,
          alpha: true,
          powerPreference: "high-performance",
        }}
      >
        <ambientLight intensity={0.6} />
        <directionalLight position={[10, 10, 5]} intensity={1.5} />
        <pointLight position={[-10, -10, -5]} intensity={1} color="#fbbf24" />

        <Center>
          <GlassArtifact />
        </Center>

        <Environment preset="city" />
      </Canvas>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Using standard `opacity: 0.5` on opaque 3D materials and calling it "glassmorphism".
- Prohibited: Omitting Environment maps, which causes `MeshTransmissionMaterial` to produce black refractive artifacts.
- Prohibited: Setting `samples > 32` or `resolution > 1024` indiscriminately, resulting in severe GPU thermal throttling on mobile hardware.
- Prohibited: Static, unlit 3D spheres placed without depth-of-field, specular highlights, or floor shadows.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-R3F-001 (Ubiquitous): The 3D render pipeline SHALL employ physical transmission shaders with explicit IOR calculations between 1.45 and 1.58.
- REQ-R3F-002 (Ubiquitous): The canvas container SHALL adapt dynamically to host pixel ratios capped at `dpr={[1, 2]}` to prevent GPU memory saturation.
- REQ-R3F-003 (State-Driven): WHILE the browser tab is hidden or minimized, the canvas execution loop SHALL suspend rendering via `frameloop="demand"` to preserve battery and compute.
- REQ-R3F-004 (Unwanted Behavior): IF the rendering loop drops below 45 FPS over 120 consecutive frames, THEN the transmission shader SHALL downscale transmission samples from 16 to 8.
