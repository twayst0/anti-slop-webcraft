# Skill 02: Typography Hierarchy & Tabular Telemetry Grid

## 1. System Invariants

1. Dual-Pairing Mandate:
   - Primary Display Font: High-character technical grotesque (e.g., Clash Display, Syne, PP Neue Montreal, Plus Jakarta Sans with alternate cuts).
   - Telemetry & Metadata Font: High-contrast tabular monospace (e.g., JetBrains Mono, Fira Code, Commit Mono) for all numeric metrics, timestamps, and status badges.
2. Tabular Numeric Grounding:
   - All dynamic numbers, counters, timestamps, and percentages MUST declare `font-variant-numeric: tabular-nums; font-feature-settings: "tnum";`.
3. Fluid Typography Calculations:
   - Typography scales dynamically via CSS `clamp()` functions instead of brittle breakpoint jumps.
   - Display: `clamp(2.25rem, 5vw + 1rem, 5.5rem)`.
   - Sub-headline: `clamp(1.125rem, 2vw + 0.5rem, 1.75rem)`.
   - Telemetry: `clamp(0.75rem, 0.5vw + 0.5rem, 0.875rem)`.
4. Zero-Emoji Protocol:
   - Absolute prohibition on unicode emojis (no rocket, checkmark, lightning, lightbulb, cross, or generic emoji icons).
   - Standardize on bespoke single-weight inline SVGs or `@phosphor-icons/react` configured with `stroke-width="1.5"`.

## 2. Production Implementation

### Fluid Typography & Grid Styles (`typography.css`)

```css
:root {
  --font-display: "Clash Display", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --font-telemetry: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, monospace;

  --type-display-hero: clamp(2.5rem, 6vw + 1rem, 6rem);
  --type-heading-lg: clamp(1.75rem, 3.5vw + 0.5rem, 3.25rem);
  --type-body-base: clamp(0.95rem, 0.5vw + 0.8rem, 1.125rem);
  --type-telemetry: clamp(0.75rem, 0.3vw + 0.65rem, 0.875rem);
}

.text-hero {
  font-family: var(--font-display);
  font-size: var(--type-display-hero);
  line-height: 0.95;
  letter-spacing: -0.04em;
  font-weight: 700;
}

.text-telemetry {
  font-family: var(--font-telemetry);
  font-size: var(--type-telemetry);
  line-height: 1.2;
  letter-spacing: 0.04em;
  font-variant-numeric: tabular-nums;
  text-transform: uppercase;
}
```

### Telemetry Cockpit Header & Asymmetric Layout (`TelemetryHeader.tsx`)

```tsx
import React from "react";
import { TerminalWindow, Cpu, Activity, ShieldCheck } from "@phosphor-icons/react";

interface MetricItem {
  id: string;
  label: string;
  value: string;
  unit: string;
  delta: string;
}

const METRICS: MetricItem[] = [
  { id: "fps", label: "RENDER_CADENCE", value: "59.94", unit: "FPS", delta: "+0.02" },
  { id: "mem", label: "GPU_BUFFER", value: "142.8", unit: "MB", delta: "-4.10" },
  { id: "lat", label: "SCRUB_LATENCY", value: "3.20", unit: "MS", delta: "NOMINAL" },
];

export const TelemetryHeader: React.FC = () => {
  return (
    <header className="w-full border-b border-[oklch(1_0_0_/_0.08)] bg-[oklch(0.12_0.015_250)] px-6 py-4">
      <div className="mx-auto flex max-w-7xl items-center justify-between">
        {/* Brand System */}
        <div className="flex items-center gap-3">
          <div className="flex h-8 w-8 items-center justify-center rounded border border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.18_0.022_250)] text-[oklch(0.85_0.18_85)]">
            <TerminalWindow size={18} weight="regular" />
          </div>
          <div className="flex flex-col">
            <span className="font-['Clash_Display'] text-sm font-semibold tracking-tight text-[oklch(0.96_0.01_250)]">
              HYPERCRAFT
            </span>
            <span className="font-mono text-[10px] uppercase tracking-widest text-[oklch(0.55_0.02_250)]">
              SYS_REV_1.0.4
            </span>
          </div>
        </div>

        {/* Real-time Telemetry Data Stream */}
        <div className="hidden items-center gap-8 md:flex">
          {METRICS.map((metric) => (
            <div key={metric.id} className="flex flex-col">
              <span className="font-mono text-[10px] uppercase tracking-wider text-[oklch(0.55_0.02_250)]">
                {metric.label}
              </span>
              <div className="flex items-baseline gap-1 font-mono text-xs tabular-nums text-[oklch(0.92_0.01_250)]">
                <span className="font-semibold">{metric.value}</span>
                <span className="text-[10px] text-[oklch(0.55_0.02_250)]">{metric.unit}</span>
                <span className="ml-1 text-[10px] text-[oklch(0.88_0.19_145)]">{metric.delta}</span>
              </div>
            </div>
          ))}
        </div>

        {/* Security & State Indicators (Pure SVGs) */}
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2 rounded border border-[oklch(0.88_0.19_145_/_0.3)] bg-[oklch(0.88_0.19_145_/_0.08)] px-2.5 py-1 text-[oklch(0.88_0.19_145)]">
            <ShieldCheck size={14} weight="regular" />
            <span className="font-mono text-[10px] font-medium uppercase tracking-wider">
              VERIFIED
            </span>
          </div>
        </div>
      </div>
    </header>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Using Inter font family as an unconsidered default for both display and data.
- Prohibited: The clichéd triad of Space Grotesk + Instrument Serif + Geist applied without explicit design justification.
- Prohibited: Standardizing on emoji icons (e.g., rocket for launch, lightning for fast, cross for errors).
- Prohibited: Numeric metrics rendered with proportional fonts that cause horizontal jitter during real-time value updates.
- Prohibited: Symmetrical, centered three-column card grids without asymmetric focal dominance.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-TYP-001 (Ubiquitous): The application SHALL render all numeric values, telemetry labels, and status badges in a monospace typeface with `tabular-nums` enabled.
- REQ-TYP-002 (Ubiquitous): The codebase SHALL contain zero occurrences of unicode emoji codepoints in HTML, JSX, CSS pseudo-elements, or logs.
- REQ-TYP-003 (State-Driven): WHILE viewport width scales between 320px and 2560px, hero display typography SHALL resize continuously according to mathematical `clamp()` rules without horizontal overflow.
- REQ-TYP-004 (Unwanted Behavior): IF a component updates dynamic telemetry figures at 60 FPS, THEN the parent container SHALL maintain an invariant pixel width with zero layout shift (CLS = 0).
