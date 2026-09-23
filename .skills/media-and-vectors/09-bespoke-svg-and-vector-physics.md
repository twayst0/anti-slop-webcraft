# Skill 09: Bespoke SVG Geometry, Vector Physics & Telemetry HUDs

## 1. System Invariants

1. Mathematical Hairline Vector Precision:
   - Stroke Weights: Standardize strictly on `1.0px` or `1.5px` hairline paths with `stroke-linecap="round"` and `stroke-linejoin="round"`.
   - Responsive Scaling: Always declare `viewBox` coordinates (e.g., `0 0 400 400`) and preserve aspect ratios using `preserveAspectRatio="xMidYMid meet"`.
2. Optical Specular Glows:
   - Apply vector glows using pure SVG `<filter>` primitives (e.g., `<feGaussianBlur stdDeviation="2"/>`) combined with `<feMerge>`.
   - Never rely on CSS `box-shadow` or blurry PNG raster glows around vector lines.
3. Dashoffset Kinematics:
   - Calculate exact path length via `path.getTotalLength()` or explicit normalized units (`pathLength="1"`) for stroke drawing animations.
   - Employ spring damping for vector gauge indicators.

## 2. Production Implementation

### Vector Radar & Oscilloscope HUD (`VectorTelemetryHUD.tsx`)

```tsx
import React, { useEffect, useRef } from "react";
import { motion } from "framer-motion";

export const VectorTelemetryHUD: React.FC = () => {
  const pathRef = useRef<SVGPathElement>(null);

  // Generate dynamic sinusoidal oscilloscope wave
  const generateWavePath = (offset: number) => {
    const points: string[] = [];
    const width = 300;
    const height = 100;
    const midY = height / 2;
    
    for (let x = 0; x <= width; x += 4) {
      const angle = (x / width) * Math.PI * 4 + offset;
      const y = midY + Math.sin(angle) * 24 * Math.cos(angle * 0.5);
      points.push(`${x === 0 ? "M" : "L"} ${x} ${y.toFixed(2)}`);
    }
    return points.join(" ");
  };

  return (
    <div className="relative flex flex-col items-center justify-center rounded-2xl border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.14_0.018_250)] p-8">
      {/* Background SVG Grid and Coordinate Marks */}
      <svg
        viewBox="0 0 320 200"
        className="h-48 w-full max-w-sm select-none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <defs>
          <pattern id="hud-grid" width="20" height="20" patternUnits="userSpaceOnUse">
            <path
              d="M 20 0 L 0 0 0 20"
              fill="none"
              stroke="oklch(1 0 0 / 0.05)"
              strokeWidth="0.75"
            />
          </pattern>
          <filter id="neon-glow" x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur stdDeviation="2.5" result="coloredBlur" />
            <feMerge>
              <feMergeNode in="coloredBlur" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
        </defs>

        {/* Coordinate Plane Grid */}
        <rect width="320" height="200" fill="url(#hud-grid)" />

        {/* Reticle Radar Circles */}
        <circle
          cx="160"
          cy="100"
          r="80"
          fill="none"
          stroke="oklch(1 0 0 / 0.1)"
          strokeWidth="1"
          strokeDasharray="4 4"
        />
        <circle
          cx="160"
          cy="100"
          r="40"
          fill="none"
          stroke="oklch(0.85 0.18 85 / 0.25)"
          strokeWidth="1"
        />

        {/* Crosshair Hairlines */}
        <line x1="160" y1="10" x2="160" y2="190" stroke="oklch(1 0 0 / 0.1)" strokeWidth="1" />
        <line x1="10" y1="100" x2="310" y2="100" stroke="oklch(1 0 0 / 0.1)" strokeWidth="1" />

        {/* Sweep Sweep Animation */}
        <motion.line
          x1="160"
          y1="100"
          x2="240"
          y2="100"
          stroke="oklch(0.85 0.18 85 / 0.8)"
          strokeWidth="1.5"
          filter="url(#neon-glow)"
          animate={{ rotate: 360 }}
          transition={{ repeat: Infinity, duration: 4, ease: "linear" }}
          style={{ originX: "160px", originY: "100px" }}
        />

        {/* Oscilloscope Kinetic Waveform */}
        <motion.path
          d={generateWavePath(0)}
          fill="none"
          stroke="oklch(0.88 0.19 145)"
          strokeWidth="1.5"
          strokeLinecap="round"
          filter="url(#neon-glow)"
          animate={{
            d: [generateWavePath(0), generateWavePath(Math.PI), generateWavePath(Math.PI * 2)],
          }}
          transition={{ repeat: Infinity, duration: 2.5, ease: "linear" }}
        />
      </svg>

      {/* Telemetry Readout Footnote */}
      <div className="mt-4 flex w-full justify-between font-mono text-[10px] text-[oklch(0.55_0.02_250)]">
        <span>VECTOR_RENDER: GPU_HAIRLINE</span>
        <span>STATUS: FREQ_LOCKED [144 HZ]</span>
      </div>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Using raster PNG/JPG icons that artifact on high-density Retina or 4K displays.
- Prohibited: Mixing varied stroke weights (e.g., 1px alongside 4px and 2.5px haphazardly) within the same icon set.
- Prohibited: Overloading complex vector paths with massive CSS filter drop shadows that crush browser compositor threads.
- Prohibited: Omission of `vector-effect="non-scaling-stroke"`, causing lines to thicken uncontrollably during coordinate scaling.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-VEC-001 (Ubiquitous): All vector graphics SHALL define explicit `viewBox` coordinates and preserve crisp rendering across 1x, 2x, and 3x screen densities.
- REQ-VEC-002 (Ubiquitous): Stroke paths SHALL maintain uniform hairline thickness (`1.0px` or `1.5px`) without arbitrary weight deviations.
- REQ-VEC-003 (State-Driven): WHILE dynamic wave paths animate in the HUD, continuous frame budget SHALL remain under 3ms.
- REQ-VEC-004 (Unwanted Behavior): IF the SVG scale increases dynamically, THEN the stroke lines SHALL utilize `vector-effect="non-scaling-stroke"` to prevent optical bloat.
