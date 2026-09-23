# Skill 24: Content-Aware Shimmer Skeletons & Zero-CLS Progressive Reveals

## 1. System Invariants

1. Zero Layout Shift Reservation (CLS = 0.000):
   - Shimmer skeleton placeholders MUST reserve the exact bounding box, padding, line-height, and aspect ratio of the incoming loaded content.
   - The document layout tree must experience ZERO dimensional shifts when replacing skeletons with hydrated components.
2. Directional Specular Shimmer Sweep:
   - Skeletons MUST employ a high-speed linear gradient sweep (`animation: shimmer 1.8s infinite linear`) translating from `-100%` to `+100%`:
     `linear-gradient(90deg, oklch(1 0 0 / 0.04) 0%, oklch(1 0 0 / 0.15) 50%, oklch(1 0 0 / 0.04) 100%)`.
   - Never use flat grey pulsing blocks (`animate-pulse` on plain `#333`).
3. Smooth Cross-Fade Transition:
   - When data resolution completes, execute a 200ms opacity cross-fade between skeleton and rendered content via Framer Motion `AnimatePresence`.

## 2. Production Implementation

### High-Fidelity Shimmer Components (`ShimmerSkeleton.tsx`)

```tsx
import React from "react";
import { motion, AnimatePresence } from "framer-motion";

interface ShimmerBaseProps {
  className?: string;
  style?: React.CSSProperties;
}

export const ShimmerBase: React.FC<ShimmerBaseProps> = ({ className = "", style }) => {
  return (
    <div
      style={style}
      className={`relative overflow-hidden rounded-lg bg-[oklch(0.16_0.02_250)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.08)] ${className}`}
    >
      {/* Directional Shimmer Sweep Layer */}
      <div
        className="pointer-events-none absolute inset-0 -translate-x-full"
        style={{
          background:
            "linear-gradient(90deg, transparent 0%, oklch(1 0 0 / 0.12) 50%, transparent 100%)",
          animation: "shimmer-sweep 1.8s infinite linear",
        }}
      />
    </div>
  );
};

export const ShimmerTelemetryCard: React.FC = () => {
  return (
    <div className="flex flex-col gap-4 rounded-2xl border border-[oklch(1_0_0_/_0.08)] bg-[oklch(0.14_0.018_250)] p-6">
      {/* Header Line */}
      <div className="flex items-center justify-between">
        <ShimmerBase className="h-4 w-32" />
        <ShimmerBase className="h-4 w-16" />
      </div>

      {/* Hero Metric Number */}
      <ShimmerBase className="h-10 w-44 rounded-xl" />

      {/* Description lines */}
      <div className="flex flex-col gap-2">
        <ShimmerBase className="h-3 w-full" />
        <ShimmerBase className="h-3 w-3/4" />
      </div>

      {/* Footer Rail */}
      <div className="flex items-center justify-between border-t border-[oklch(1_0_0_/_0.06)] pt-4">
        <ShimmerBase className="h-3 w-24" />
        <ShimmerBase className="h-3 w-20" />
      </div>
    </div>
  );
};

interface AsyncDataLoaderProps<T> {
  isLoading: boolean;
  data: T | null;
  skeleton: React.ReactNode;
  children: (data: T) => React.ReactNode;
}

export function AsyncDataLoader<T>({
  isLoading,
  data,
  skeleton,
  children,
}: AsyncDataLoaderProps<T>) {
  return (
    <AnimatePresence mode="wait">
      {isLoading || !data ? (
        <motion.div
          key="skeleton"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
        >
          {skeleton}
        </motion.div>
      ) : (
        <motion.div
          key="content"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
        >
          {children(data)}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

### Shimmer Keyframes (`shimmer.css`)

```css
@keyframes shimmer-sweep {
  100% {
    transform: translateX(100%);
  }
}
```

## 3. Prohibited Anti-Patterns

- Prohibited: Generic grey `bg-gray-700 animate-pulse` boxes that flash jarringly without directional specular shine.
- Prohibited: Skeletons that mismatch the rendered content's height or width, inducing layout reflow upon data load.
- Prohibited: Flash of unstyled content (FOUC) when font files load after skeletons are unmounted.
- Prohibited: Running multiple unsynchronized shimmer animations with conflicting speeds in adjacent cards.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-SHM-001 (Ubiquitous): Shimmer placeholders SHALL match loaded component dimensions within 0px discrepancy to preserve CLS = 0.000.
- REQ-SHM-002 (Ubiquitous): The specular gradient sweep SHALL execute purely via GPU `transform: translateX()` CSS animation.
- REQ-SHM-003 (State-Driven): WHILE asynchronous data transitions to resolved state, the skeleton SHALL cross-fade to content within 200ms.
- REQ-SHM-004 (Unwanted Behavior): IF network fetch fails, THEN the skeleton SHALL transition cleanly to an error state without collapsing layout height.
