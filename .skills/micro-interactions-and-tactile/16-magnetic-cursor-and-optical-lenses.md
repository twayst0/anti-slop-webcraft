# Skill 16: Fluid Magnetic Cursors & Optical Magnification Lenses

## 1. System Invariants

1. Pointer Precision & Media Query Quarantine:
   - Custom pointer logic MUST only activate on devices satisfying `@media (pointer: fine) and (hover: hover)`. Never suppress native touch controls on mobile or tablet devices.
2. Dual-Body Inertia Model:
   - Dot Element: Instant 1:1 position tracking with zero latency (`x.set(e.clientX), y.set(e.clientY)`).
   - Ring / Lens Element: Follows pointer with physical second-order spring dynamics (`stiffness: 250, damping: 20, mass: 0.6`).
3. Sticky Magnetic Snapping:
   - When hovering near interactive targets (`[data-magnetic]`), the cursor ring must stretch and snap to wrap the target bounding box with a 4px optical buffer.
4. Optical Difference Compositing:
   - Standardize on `mix-blend-mode: difference` with pure white fill (`oklch(1 0 0)`) so the lens maintains crisp optical inversion over both dark and light surfaces.

## 2. Production Implementation

### Complete Optical Cursor & Lens System (`OpticalCursorLens.tsx`)

```tsx
import React, { useEffect, useState } from "react";
import { motion, useMotionValue, useSpring } from "framer-motion";

export const OpticalCursorLens: React.FC = () => {
  const [isEnabled, setIsEnabled] = useState(false);
  const [isHovered, setIsHovered] = useState(false);

  const cursorX = useMotionValue(-100);
  const cursorY = useMotionValue(-100);

  const springConfig = { damping: 25, stiffness: 300, mass: 0.5 };
  const smoothX = useSpring(cursorX, springConfig);
  const smoothY = useSpring(cursorY, springConfig);

  useEffect(() => {
    // Quarantine to fine pointer devices only
    const mediaQuery = window.matchMedia("(pointer: fine) and (hover: hover)");
    if (!mediaQuery.matches) return;
    setIsEnabled(true);

    const handleMouseMove = (e: MouseEvent) => {
      cursorX.set(e.clientX);
      cursorY.set(e.clientY);

      // Check for magnetic interactive targets
      const target = (e.target as HTMLElement)?.closest("[data-magnetic]");
      setIsHovered(!!target);
    };

    window.addEventListener("mousemove", handleMouseMove);
    return () => window.removeEventListener("mousemove", handleMouseMove);
  }, [cursorX, cursorY]);

  if (!isEnabled) return null;

  return (
    <>
      {/* Precision Center Dot */}
      <motion.div
        className="pointer-events-none fixed left-0 top-0 z-50 h-1.5 w-1.5 rounded-full bg-[oklch(0.85_0.18_85)] mix-blend-difference"
        style={{
          x: cursorX,
          y: cursorY,
          translateX: "-50%",
          translateY: "-50%",
        }}
      />

      {/* Trailing Optical Lens Ring */}
      <motion.div
        className="pointer-events-none fixed left-0 top-0 z-50 rounded-full border border-[oklch(1_0_0_/_0.8)] backdrop-blur-[1px]"
        style={{
          x: smoothX,
          y: smoothY,
          translateX: "-50%",
          translateY: "-50%",
          mixBlendMode: "difference",
        }}
        animate={{
          width: isHovered ? 56 : 28,
          height: isHovered ? 56 : 28,
          backgroundColor: isHovered ? "oklch(1 0 0 / 0.15)" : "transparent",
        }}
        transition={{ type: "spring", stiffness: 350, damping: 25 }}
      />
    </>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Forcing `cursor: none` globally on mobile or touch-screen devices.
- Prohibited: Hooking `useState` inside the mouse movement listener, creating 120 FPS React re-renders.
- Prohibited: Heavy box shadows or unoptimized blur filters inside the custom cursor that cause GPU composite hitching during fast flicks.
- Prohibited: Losing cursor position when mouse exits browser viewport window.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-CUR-001 (Ubiquitous): The custom cursor system SHALL be completely inactive on touch devices lacking pointer hover support.
- REQ-CUR-002 (Ubiquitous): The cursor center dot SHALL update coordinates synchronously without frame lag.
- REQ-CUR-003 (State-Driven): WHILE pointer hovers an element with `data-magnetic`, the outer lens ring SHALL expand and adjust opacity with second-order spring dynamics.
- REQ-CUR-004 (Unwanted Behavior): IF the pointer leaves the browser window, THEN the cursor indicators SHALL hide smoothly without getting stuck at window boundaries.
