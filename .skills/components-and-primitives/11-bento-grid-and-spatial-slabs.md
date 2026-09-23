# Skill 11: Asymmetric Bento Grids, Spatial Slabs & Border Beams

## 1. System Invariants

1. Asymmetric Grid Geometry:
   - Bento layouts MUST break symmetric 3x3 repetition. Enforce intentional spatial dominance: 1 hero slab (spanning 2 rows and 2 columns), paired with 2-3 asymmetric companion slabs.
   - Standardize on CSS Grid with `auto-rows: minmax(180px, auto)` and `grid-template-columns: repeat(12, minmax(0, 1fr))`.
2. Optical Border Beam Physics:
   - Dynamic border highlights MUST use continuous animated conic or linear gradient sweeps constrained inside an inner pseudo-element with `mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0); mask-composite: exclude;`.
   - Never apply blurry outer dropshadows around bento cards.
3. Coordinated Cursor Spotlight:
   - All slabs in a bento container MUST share a unified pointer coordinate space so the spotlight illuminates slab borders continuously across gutter boundaries.

## 2. Production Implementation

### Bento Grid with Coordinated Border Beam (`BentoSpatialGrid.tsx`)

```tsx
import React, { useRef } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import { Cpu, ShieldCheck, HardDrives, Activity, ArrowUpRight } from "@phosphor-icons/react";

interface BentoCardProps {
  children: React.ReactNode;
  colSpan?: string;
  rowSpan?: string;
  className?: string;
  showBeam?: boolean;
}

export const BentoCard: React.FC<BentoCardProps> = ({
  children,
  colSpan = "col-span-12 md:col-span-4",
  rowSpan = "row-span-1",
  className = "",
  showBeam = false,
}) => {
  return (
    <div
      className={`group relative overflow-hidden rounded-2xl border border-[oklch(1_0_0_/_0.08)] bg-[oklch(0.14_0.018_250)] p-6 shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.15)] backdrop-blur-xl transition-all duration-300 hover:border-[oklch(1_0_0_/_0.18)] ${colSpan} ${rowSpan} ${className}`}
    >
      {/* Animated Border Beam Highlight */}
      {showBeam && (
        <div
          className="pointer-events-none absolute -inset-px rounded-2xl opacity-0 transition-opacity duration-500 group-hover:opacity-100"
          style={{
            background:
              "conic-gradient(from 0deg at 50% 50%, transparent 0deg, transparent 280deg, oklch(0.85 0.18 85) 320deg, transparent 360deg)",
            animation: "border-beam-spin 4s linear infinite",
            mask: "linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)",
            maskComposite: "exclude",
            padding: "1px",
          }}
        />
      )}

      {/* Surface Ambient Glow */}
      <div className="pointer-events-none absolute -right-16 -top-16 h-36 w-36 rounded-full bg-[oklch(0.85_0.18_85_/_0.04)] blur-2xl transition-all duration-500 group-hover:scale-150 group-hover:bg-[oklch(0.85_0.18_85_/_0.08)]" />

      <div className="relative z-10 flex h-full flex-col justify-between">{children}</div>
    </div>
  );
};

export const BentoShowcase: React.FC = () => {
  return (
    <div className="mx-auto grid max-w-6xl grid-cols-12 gap-4 p-4">
      {/* Hero Spatial Slab */}
      <BentoCard colSpan="col-span-12 md:col-span-8" rowSpan="row-span-2" showBeam={true}>
        <div className="flex items-center justify-between border-b border-[oklch(1_0_0_/_0.06)] pb-4">
          <div className="flex items-center gap-2">
            <Cpu size={16} weight="regular" className="text-[oklch(0.85_0.18_85)]" />
            <span className="font-mono text-xs uppercase tracking-wider text-[oklch(0.65_0.02_250)]">
              SYSTEM_ORCHESTRATOR
            </span>
          </div>
          <span className="rounded bg-[oklch(0.88_0.19_145_/_0.1)] px-2 py-0.5 font-mono text-[10px] text-[oklch(0.88_0.19_145)]">
            LIVE_PIPELINE
          </span>
        </div>

        <div className="my-8">
          <h3 className="font-['Clash_Display'] text-3xl font-bold tracking-tight text-[oklch(0.96_0.01_250)] md:text-4xl">
            Autonomous Neural Scheduling with Zero Latency
          </h3>
          <p className="mt-2 text-sm text-[oklch(0.65_0.02_250)]">
            Continuous hardware acceleration balancing multi-threaded WebGL pipelines at sub-millisecond execution cycles.
          </p>
        </div>

        <div className="flex items-center justify-between border-t border-[oklch(1_0_0_/_0.06)] pt-4 font-mono text-xs text-[oklch(0.55_0.02_250)]">
          <span>THROUGHPUT: 94.2%</span>
          <span className="flex items-center gap-1 text-[oklch(0.85_0.18_85)]">
            EXPLORE SPEC <ArrowUpRight size={12} weight="bold" />
          </span>
        </div>
      </BentoCard>

      {/* Secondary Companion Slab */}
      <BentoCard colSpan="col-span-12 md:col-span-4" showBeam={false}>
        <div className="flex items-center gap-2 border-b border-[oklch(1_0_0_/_0.06)] pb-3">
          <ShieldCheck size={16} weight="regular" className="text-[oklch(0.88_0.19_145)]" />
          <span className="font-mono text-xs uppercase tracking-wider text-[oklch(0.65_0.02_250)]">
            ENCLAVE_SECURITY
          </span>
        </div>
        <div className="my-4">
          <span className="font-mono text-2xl font-bold tabular-nums text-[oklch(0.96_0.01_250)]">
            100%
          </span>
          <p className="mt-1 text-xs text-[oklch(0.65_0.02_250)]">Immutable hardware isolation keys</p>
        </div>
      </BentoCard>

      {/* Tertiary Telemetry Slab */}
      <BentoCard colSpan="col-span-12 md:col-span-4" showBeam={false}>
        <div className="flex items-center gap-2 border-b border-[oklch(1_0_0_/_0.06)] pb-3">
          <HardDrives size={16} weight="regular" className="text-[oklch(0.82_0.14_200)]" />
          <span className="font-mono text-xs uppercase tracking-wider text-[oklch(0.65_0.02_250)]">
            EDGE_CACHING
          </span>
        </div>
        <div className="my-4">
          <span className="font-mono text-2xl font-bold tabular-nums text-[oklch(0.96_0.01_250)]">
            1.2ms
          </span>
          <p className="mt-1 text-xs text-[oklch(0.65_0.02_250)]">Global transit latency budget</p>
        </div>
      </BentoCard>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Uniform 3x3 grids of identical cards with identical padding and font sizing.
- Prohibited: Border beams rendered via DOM canvas redraws on every scroll tick.
- Prohibited: Generic purple-to-pink gradient border borders (`from-purple-500 to-pink-500`).
- Prohibited: Unresponsive fixed pixel heights on bento cells causing content truncation on small viewports.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-BTO-001 (Ubiquitous): Bento grid containers SHALL enforce asymmetric hierarchy with at least one cell occupying minimum 2x area of adjacent cells.
- REQ-BTO-002 (Ubiquitous): Border beam sweeps SHALL run via CSS composited keyframe animations with zero JavaScript thread execution.
- REQ-BTO-003 (State-Driven): WHILE on mobile viewports (< 768px), the 12-column bento layout SHALL collapse into a single stacked column with auto heights.
- REQ-BTO-004 (Unwanted Behavior): IF a bento card content exceeds default dimensions, THEN the grid row SHALL expand dynamically without layout clipping.
