# Skill 13: Animated Curvature Beams & Dynamic Connection Graphs

## 1. System Invariants

1. Mathematical Cubic Bezier Anchoring:
   - Dynamic connection beams between DOM nodes MUST compute curvature vectors from source anchor center `(x1, y1)` to target anchor center `(x2, y2)`.
   - Control points: `cp1 = (x1, (y1 + y2) / 2)`, `cp2 = (x2, (y1 + y2) / 2)` or bidirectional curvature offset `curvature = Math.abs(x2 - x1) * 0.4`.
2. Hardware Stroke Gradient Physics:
   - Beam animation MUST traverse the path using an animated `<linearGradient>` with moving gradient stops or `<motion.path>` stroke dashoffset.
   - Base hairline background path (`stroke="oklch(1 0 0 / 0.08)"`) must remain visible beneath the energetic pulse.
3. DOM Resize Observer Synchronization:
   - Wrap container nodes in `ResizeObserver` to update SVG bezier control points dynamically whenever window scale or container dimensions shift.

## 2. Production Implementation

### Dynamic Curvature Beam System (`AnimatedConnectionBeam.tsx`)

```tsx
import React, { useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import { Database, Cpu, Cloud, Terminal } from "@phosphor-icons/react";

interface BeamAnchorProps {
  containerRef: React.RefObject<HTMLDivElement>;
  fromRef: React.RefObject<HTMLDivElement>;
  toRef: React.RefObject<HTMLDivElement>;
  curvature?: number;
  reverse?: boolean;
}

export const AnimatedBeam: React.FC<BeamAnchorProps> = ({
  containerRef,
  fromRef,
  toRef,
  curvature = 50,
  reverse = false,
}) => {
  const [pathD, setPathD] = useState("");
  const [gradientId] = useState(() => `beam-grad-${Math.random().toString(36).substr(2, 9)}`);

  useEffect(() => {
    const updatePath = () => {
      if (!containerRef.current || !fromRef.current || !toRef.current) return;

      const containerRect = containerRef.current.getBoundingClientRect();
      const fromRect = fromRef.current.getBoundingClientRect();
      const toRect = toRef.current.getBoundingClientRect();

      const startX = fromRect.left - containerRect.left + fromRect.width / 2;
      const startY = fromRect.top - containerRect.top + fromRect.height / 2;
      const endX = toRect.left - containerRect.left + toRect.width / 2;
      const endY = toRect.top - containerRect.top + toRect.height / 2;

      const deltaX = endX - startX;
      const deltaY = endY - startY;

      // Cubic bezier control points
      const cp1X = startX + deltaX * 0.5;
      const cp1Y = startY + curvature;
      const cp2X = startX + deltaX * 0.5;
      const cp2Y = endY - curvature;

      setPathD(`M ${startX} ${startY} C ${cp1X} ${cp1Y}, ${cp2X} ${cp2Y}, ${endX} ${endY}`);
    };

    updatePath();
    const resizeObserver = new ResizeObserver(updatePath);
    if (containerRef.current) resizeObserver.observe(containerRef.current);
    window.addEventListener("resize", updatePath);

    return () => {
      resizeObserver.disconnect();
      window.removeEventListener("resize", updatePath);
    };
  }, [containerRef, fromRef, toRef, curvature]);

  return (
    <svg className="pointer-events-none absolute inset-0 h-full w-full overflow-visible">
      <defs>
        <motion.linearGradient
          id={gradientId}
          gradientUnits="userSpaceOnUse"
          initial={{ x1: "0%", x2: "0%", y1: "0%", y2: "0%" }}
          animate={
            reverse
              ? { x1: ["100%", "0%"], x2: ["120%", "20%"] }
              : { x1: ["0%", "100%"], x2: ["20%", "120%"] }
          }
          transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
        >
          <stop stopColor="oklch(0.85 0.18 85)" stopOpacity="0" />
          <stop stopColor="oklch(0.85 0.18 85)" stopOpacity="1" />
          <stop offset="32.5%" stopColor="oklch(0.88 0.19 145)" stopOpacity="1" />
          <stop offset="100%" stopColor="oklch(0.88 0.19 145)" stopOpacity="0" />
        </motion.linearGradient>
      </defs>

      {/* Static Substrate Hairline */}
      <path d={pathD} stroke="oklch(1 0 0 / 0.08)" strokeWidth="1.5" fill="none" />

      {/* Energetic High-Speed Transmission Pulse */}
      <path
        d={pathD}
        stroke={`url(#${gradientId})`}
        strokeWidth="2"
        strokeLinecap="round"
        fill="none"
      />
    </svg>
  );
};

export const ArchitectureGraph: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null!);
  const clientRef = useRef<HTMLDivElement>(null!);
  const gatewayRef = useRef<HTMLDivElement>(null!);
  const databaseRef = useRef<HTMLDivElement>(null!);

  return (
    <div
      ref={containerRef}
      className="relative flex h-80 w-full max-w-2xl items-center justify-between rounded-2xl border border-[oklch(1_0_0_/_0.08)] bg-[oklch(0.12_0.015_250)] p-12"
    >
      <AnimatedBeam containerRef={containerRef} fromRef={clientRef} toRef={gatewayRef} curvature={-30} />
      <AnimatedBeam containerRef={containerRef} fromRef={gatewayRef} toRef={databaseRef} curvature={30} />

      {/* Node 1: Client */}
      <div
        ref={clientRef}
        className="z-10 flex h-14 w-14 items-center justify-center rounded-2xl border border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.18_0.022_250)] text-[oklch(0.85_0.18_85)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.2)]"
      >
        <Terminal size={24} weight="regular" />
      </div>

      {/* Node 2: Gateway */}
      <div
        ref={gatewayRef}
        className="z-10 flex h-16 w-16 items-center justify-center rounded-2xl border border-[oklch(0.85_0.18_85_/_0.3)] bg-[oklch(0.20_0.025_250)] text-[oklch(0.96_0.01_250)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.3),0_0_24px_oklch(0.85_0.18_85_/_0.15)]"
      >
        <Cpu size={28} weight="regular" />
      </div>

      {/* Node 3: Storage */}
      <div
        ref={databaseRef}
        className="z-10 flex h-14 w-14 items-center justify-center rounded-2xl border border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.18_0.022_250)] text-[oklch(0.88_0.19_145)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.2)]"
      >
        <Database size={24} weight="regular" />
      </div>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Straight, uncurved SVG lines rendered without cubic bezier physics.
- Prohibited: Polling `getBoundingClientRect()` inside continuous `requestAnimationFrame` loops when `ResizeObserver` handles layout changes natively.
- Prohibited: Heavy blur filters on animated SVG paths that cause CPU compositing degradation.
- Prohibited: Missing container overflow handling leading to horizontal scrollbar flickers during beam progression.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-BEM-001 (Ubiquitous): Connection paths SHALL calculate cubic bezier anchors dynamically from element centers via bounding rect matrices.
- REQ-BEM-002 (Ubiquitous): The gradient stroke progression SHALL run through SVG hardware-accelerated transforms without triggering DOM repaints.
- REQ-BEM-003 (State-Driven): WHILE container elements reposition during viewport changes, beam coordinate paths SHALL recalibrate synchronously.
- REQ-BEM-004 (Unwanted Behavior): IF start or target element references are unmounted, THEN the SVG path rendering SHALL abort cleanly without console exceptions.
