# Skill 07: Framer Motion Physical Springs & Interactive Spotlight Surfaces

## 1. System Invariants

1. Physical Springs Over Easing Curves:
   - Ban generic CSS easing (`transition: all 0.3s ease-in-out`).
   - Default all micro-interactions to second-order spring dynamics:
     - Snappy CTA Springs: `{ type: "spring", stiffness: 400, damping: 30 }`
     - Ambient Drag/Floating Springs: `{ type: "spring", stiffness: 180, damping: 22, mass: 1 }`
     - Layout Transitions: `{ type: "spring", stiffness: 260, damping: 28 }`
2. Hardware Transform Confinement:
   - Animate ONLY GPU-composited properties: `transform` (`x`, `y`, `scale`, `rotate`) and `opacity`.
   - Never animate layout-triggering properties (`width`, `height`, `top`, `margin`, `padding`). Utilize Framer Motion `layout` or `layoutId` for structural morphing.
3. Spotlight Coordinates & Pointer Tracking:
   - Track cursor positions using damped `useMotionValue` and `useSpring` rather than triggering React state re-renders on `mousemove`.

## 2. Production Implementation

### Magnetic Button & Spotlight Card Container (`InteractiveMotionKit.tsx`)

```tsx
import React, { useRef } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import { ArrowUpRight } from "@phosphor-icons/react";

interface SpotlightCardProps {
  children: React.ReactNode;
  className?: string;
}

export const SpotlightCard: React.FC<SpotlightCardProps> = ({
  children,
  className = "",
}) => {
  const mouseX = useMotionValue(-1000);
  const mouseY = useMotionValue(-1000);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    mouseX.set(e.clientX - rect.left);
    mouseY.set(e.clientY - rect.top);
  };

  const handleMouseLeave = () => {
    mouseX.set(-1000);
    mouseY.set(-1000);
  };

  return (
    <div
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className={`group relative overflow-hidden rounded-2xl border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.16_0.02_250)] p-8 shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.18)] ${className}`}
    >
      {/* Optical Spotlight Layer */}
      <motion.div
        className="pointer-events-none absolute -inset-px opacity-0 transition-opacity duration-300 group-hover:opacity-100"
        style={{
          background: useTransform(
            [mouseX, mouseY],
            ([x, y]) =>
              `radial-gradient(600px circle at ${x}px ${y}px, oklch(0.85 0.18 85 / 0.12), transparent 70%)`
          ),
        }}
      />
      <div className="relative z-10">{children}</div>
    </div>
  );
};

interface MagneticButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  className?: string;
}

export const MagneticButton: React.FC<MagneticButtonProps> = ({
  children,
  onClick,
  className = "",
}) => {
  const ref = useRef<HTMLButtonElement>(null);

  const x = useMotionValue(0);
  const y = useMotionValue(0);

  // Calibrated spring physics
  const springX = useSpring(x, { stiffness: 350, damping: 20, mass: 0.5 });
  const springY = useSpring(y, { stiffness: 350, damping: 20, mass: 0.5 });

  const handleMouseMove = (e: React.MouseEvent<HTMLButtonElement>) => {
    if (!ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    // Magnetic pull displacement factor
    x.set((e.clientX - centerX) * 0.35);
    y.set((e.clientY - centerY) * 0.35);
  };

  const handleMouseLeave = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.button
      ref={ref}
      onClick={onClick}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{ x: springX, y: springY }}
      whileTap={{ scale: 0.96 }}
      className={`relative inline-flex items-center gap-2 rounded-xl border border-[oklch(0.85_0.18_85_/_0.3)] bg-[oklch(0.85_0.18_85_/_0.1)] px-6 py-3 font-mono text-xs uppercase tracking-wider text-[oklch(0.85_0.18_85)] shadow-[inset_0_1px_0_0_oklch(0.85_0.18_85_/_0.4)] backdrop-blur-md transition-colors hover:bg-[oklch(0.85_0.18_85_/_0.2)] ${className}`}
    >
      <span>{children}</span>
      <ArrowUpRight size={14} weight="bold" />
    </motion.button>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Storing mouse coordinates in standard React state (`useState`) during rapid pointer moves, triggering catastrophic render storms.
- Prohibited: Using transition shorthand `transition: all 0.2s` which causes layout reflows on computed geometry.
- Prohibited: Unbounded magnetic pull distance that detaches the button completely from its hit target area.
- Prohibited: Missing `will-change: transform` or `transform: translateZ(0)` on continuously morphing elements.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-MOT-001 (Ubiquitous): Interactive buttons and cursor-following elements SHALL use physical spring calculations (`stiffness` and `damping`) with zero linear easing.
- REQ-MOT-002 (Ubiquitous): Spotlight surface gradient positions SHALL update via reactive MotionValues outside the React component reconciliation cycle.
- REQ-MOT-003 (State-Driven): WHILE pointer enters a magnetic interactive boundary, the element SHALL attract toward pointer center up to a maximum offset of 24 pixels.
- REQ-MOT-004 (Unwanted Behavior): IF pointer leaves the interactive hit box, THEN the element SHALL snap back to its origin without oscillation ringing exceeding 250 milliseconds.
