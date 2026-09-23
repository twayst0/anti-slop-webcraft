# Skill 05: Interactive 3D Device Mockups & Floating HUD Overlays

## 1. System Invariants

1. Damped Spatial Kinematics:
   - All cursor-reactive 3D transforms MUST incorporate physical damping (`dampingFactor: 0.05` to `0.08`). Never allow 1:1 rigid angular snapping to pointer coordinates.
   - Max Pitch & Yaw Angles: Constrain tilt angles between `-15deg` and `+15deg` to preserve readability and layout anchoring.
2. Hybrid DOM & 3D Integration:
   - Utilize `@react-three/drei` `Html` components with `transform`, `occlude`, and `distanceFactor` props for high-density spatial HUD tags.
   - Screen Space CSS scaling must synchronize precisely with 3D camera zoom depth.
3. Hardware Acceleration & Mobile Fallbacks:
   - Provide touch event gyroscope / accelerometer fallbacks or auto-oscillating idle animations for non-pointer devices.

## 2. Production Implementation

### 3D Hardware Frame with Floating HUD (`Interactive3DMockup.tsx`)

```tsx
import React, { useRef } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { Float, RoundedBox, Html, PresentationControls } from "@react-three/drei";
import * as THREE from "three";
import { Cpu, Pulse, HardDrives } from "@phosphor-icons/react";

const DeviceChassis: React.FC = () => {
  const meshRef = useRef<THREE.Group>(null!);

  useFrame((state) => {
    // Subtle physical breathing motion
    const t = state.clock.getElapsedTime();
    meshRef.current.position.y = Math.sin(t * 1.5) * 0.05;
  });

  return (
    <group ref={meshRef}>
      {/* Precision Aluminum Unibody Chassis */}
      <RoundedBox args={[3.2, 2.0, 0.12]} radius={0.06} smoothness={8} castShadow receiveShadow>
        <meshPhysicalMaterial
          color="#1e222b"
          metalness={0.92}
          roughness={0.18}
          clearcoat={0.3}
          clearcoatRoughness={0.1}
        />
      </RoundedBox>

      {/* High-Gloss Display Bezel */}
      <RoundedBox args={[3.08, 1.88, 0.02]} position={[0, 0, 0.06]} radius={0.03} smoothness={4}>
        <meshBasicMaterial color="#08090c" />
      </RoundedBox>

      {/* Spatial HUD Overlay 01: Telemetry Badge */}
      <Html
        position={[-1.3, 0.75, 0.15]}
        transform
        distanceFactor={3}
        className="pointer-events-none select-none"
      >
        <div className="flex items-center gap-2 rounded border border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.18_0.022_250_/_0.85)] px-2.5 py-1 backdrop-blur-md">
          <Cpu size={12} weight="regular" className="text-[oklch(0.85_0.18_85)]" />
          <span className="font-mono text-[9px] uppercase tracking-wider text-[oklch(0.96_0.01_250)]">
            NEURAL_CORE: ACTIVE
          </span>
        </div>
      </Html>

      {/* Spatial HUD Overlay 02: Performance Metric */}
      <Html
        position={[1.1, -0.65, 0.15]}
        transform
        distanceFactor={3}
        className="pointer-events-none select-none"
      >
        <div className="flex items-center gap-2 rounded border border-[oklch(0.88_0.19_145_/_0.3)] bg-[oklch(0.12_0.015_250_/_0.9)] px-2.5 py-1 backdrop-blur-md">
          <Pulse size={12} weight="regular" className="text-[oklch(0.88_0.19_145)]" />
          <span className="font-mono text-[9px] tabular-nums text-[oklch(0.88_0.19_145)]">
            99.98% STABLE
          </span>
        </div>
      </Html>
    </group>
  );
};

export const Interactive3DStage: React.FC = () => {
  return (
    <div className="relative h-[500px] w-full cursor-grab active:cursor-grabbing">
      <Canvas
        camera={{ position: [0, 0, 4.5], fov: 42 }}
        dpr={[1, 2]}
        gl={{ antialias: true, alpha: true, powerPreference: "high-performance" }}
      >
        <ambientLight intensity={0.5} />
        <directionalLight position={[5, 8, 4]} intensity={2.0} color="#ffffff" />
        <pointLight position={[-4, -3, 2]} intensity={0.8} color="#f59e0b" />

        <PresentationControls
          global={false}
          cursor={true}
          snap={{ mass: 2, tension: 250 }}
          speed={1.5}
          zoom={1}
          rotation={[0, 0, 0]}
          polar={[-Math.PI / 8, Math.PI / 8]}
          azimuth={[-Math.PI / 6, Math.PI / 6]}
        >
          <Float speed={1.5} rotationIntensity={0.2} floatIntensity={0.3}>
            <DeviceChassis />
          </Float>
        </PresentationControls>
      </Canvas>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Raw mouse coordinate mapping directly to mesh rotation without lerp or spring physics.
- Prohibited: Unbounded OrbitControls allowing users to flip mockups upside down or clip inside geometry.
- Prohibited: Low-resolution flat screenshot textures slapped onto unlit box geometry.
- Prohibited: Forgetting pointer events configuration (`pointer-events-none` on informational HUD tags) causing cursor interaction stutter.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-MOCK-001 (Ubiquitous): The 3D viewport SHALL constrain polar and azimuth rotation within strict mechanical bounds (+/-25 degrees maximum).
- REQ-MOCK-002 (Ubiquitous): When released by the user, the 3D frame SHALL spring back to rest position using a second-order spring calculation.
- REQ-MOCK-003 (State-Driven): WHILE pointer hover moves across the viewport, spatial HUD tags SHALL maintain crisp vector text rendering without blur or subpixel shimmering.
- REQ-MOCK-004 (Unwanted Behavior): IF touch devices lack cursor hover events, THEN the system SHALL initiate an ambient mathematical floating trajectory.
