# Skill 19: Infinite GPU Marquees & Velocity-Responsive Carousels

## 1. System Invariants

1. Pure GPU Translation Geometry:
   - Marquee tracks MUST translate solely along `transform: translate3d(x, 0, 0)`.
   - Never animate `margin-left`, `left`, or scroll offsets which force browser layout recalculation and paint cascades.
2. Velocity Dampening & Hover Physics:
   - On cursor hover or pointer grab, marquee speed must decelerate using damped spring physics rather than instantly freezing on a single frame.
3. DOM Recycling & Infinite Wrapping:
   - Wrap elements seamlessly at -50% translation without spawning unbounded duplicate clones.
   - Use CSS `@keyframes marquee { 0% { transform: translate3d(0,0,0); } 100% { transform: translate3d(-50%,0,0); } }`.

## 2. Production Implementation

### High-Performance Infinite Marquee Track (`InfiniteMarquee.tsx`)

```tsx
import React, { useRef } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";

interface MarqueeItem {
  id: string;
  label: string;
  badge: string;
}

const ITEMS: MarqueeItem[] = [
  { id: "01", label: "OKLCH_60_30_10_ENGINE", badge: "COLOR" },
  { id: "02", label: "GSAP_LENIS_SCRUB_SYNC", badge: "MOTION" },
  { id: "03", label: "MESH_TRANSMISSION_IOR_1.52", badge: "3D_OPTICS" },
  { id: "04", label: "ZERO_EMOJI_ENFORCEMENT", badge: "TYPOGRAPHY" },
  { id: "05", label: "GPU_CURL_NOISE_SIMULATION", badge: "SHADERS" },
  { id: "06", label: "TABULAR_NUMERIC_TELEMETRY", badge: "DATA" },
];

interface InfiniteMarqueeProps {
  speed?: number;
  reverse?: boolean;
  className?: string;
}

export const InfiniteMarquee: React.FC<InfiniteMarqueeProps> = ({
  speed = 30,
  reverse = false,
  className = "",
}) => {
  return (
    <div
      className={`group relative flex w-full overflow-hidden border-y border-[oklch(1_0_0_/_0.08)] bg-[oklch(0.12_0.015_250)] py-3 ${className}`}
    >
      {/* Edge Feather Masks */}
      <div className="pointer-events-none absolute left-0 top-0 z-10 h-full w-24 bg-gradient-to-r from-[oklch(0.12_0.015_250)] to-transparent" />
      <div className="pointer-events-none absolute right-0 top-0 z-10 h-full w-24 bg-gradient-to-l from-[oklch(0.12_0.015_250)] to-transparent" />

      {/* Continuously Translating Track (Duplicated once for seamless wrap) */}
      <div
        className="flex min-w-full shrink-0 items-center justify-around gap-8 transition-transform duration-300 ease-out group-hover:[animation-play-state:paused]"
        style={{
          animation: `marquee ${speed}s linear infinite ${reverse ? "reverse" : "normal"}`,
        }}
      >
        {ITEMS.map((item) => (
          <div
            key={item.id}
            className="flex items-center gap-3 rounded-lg border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.16_0.02_250)] px-4 py-1.5 shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.15)]"
          >
            <span className="font-mono text-[9px] uppercase tracking-wider text-[oklch(0.85_0.18_85)]">
              {item.badge}
            </span>
            <span className="font-mono text-xs font-semibold tracking-wider text-[oklch(0.96_0.01_250)]">
              {item.label}
            </span>
          </div>
        ))}
      </div>

      <div
        aria-hidden="true"
        className="flex min-w-full shrink-0 items-center justify-around gap-8 transition-transform duration-300 ease-out group-hover:[animation-play-state:paused]"
        style={{
          animation: `marquee ${speed}s linear infinite ${reverse ? "reverse" : "normal"}`,
        }}
      >
        {ITEMS.map((item) => (
          <div
            key={`dup-${item.id}`}
            className="flex items-center gap-3 rounded-lg border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.16_0.02_250)] px-4 py-1.5 shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.15)]"
          >
            <span className="font-mono text-[9px] uppercase tracking-wider text-[oklch(0.85_0.18_85)]">
              {item.badge}
            </span>
            <span className="font-mono text-xs font-semibold tracking-wider text-[oklch(0.96_0.01_250)]">
              {item.label}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};
```

### Required Marquee CSS Keyframes (`marquee.css`)

```css
@keyframes marquee {
  0% {
    transform: translate3d(0, 0, 0);
  }
  100% {
    transform: translate3d(-100%, 0, 0);
  }
}
```

## 3. Prohibited Anti-Patterns

- Prohibited: Hooking scroll or translation intervals in JavaScript timers that drift and drop frames.
- Prohibited: Infinite DOM clone instantiation resulting in thousands of un-garbage-collected card elements.
- Prohibited: Animating non-transform CSS properties (`left`, `margin`), creating high browser thread CPU usage.
- Prohibited: Abrupt stopping on hover without CSS play-state easing or momentum deceleration.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-MRQ-001 (Ubiquitous): The marquee animation track SHALL translate exclusively via GPU-composited `transform: translate3d()` operations.
- REQ-MRQ-002 (Ubiquitous): The second track clone SHALL declare `aria-hidden="true"` to prevent redundant screen reader announcements.
- REQ-MRQ-003 (State-Driven): WHILE pointer hovers over the marquee track, translation SHALL pause smoothly without visual coordinate jumping.
- REQ-MRQ-004 (Unwanted Behavior): IF the viewport width changes, THEN the marquee loop point SHALL adjust seamlessly with zero gap flicker.
