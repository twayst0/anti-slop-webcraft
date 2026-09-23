# Skill 20: Tailwind CSS v4 Architecture & Zero-Runtime CLS Optimization

## 1. System Invariants

1. Zero-Runtime Design Engine:
   - Configure styles purely through Tailwind CSS v4 CSS-first `@theme` directives without JavaScript-in-CSS runtime overhead.
   - All color tokens, spacing scales, and hairline shadows MUST resolve to native CSS custom properties.
2. Zero Layout Shift Invariant (CLS = 0.000):
   - Every dynamic image, canvas, video, or 3D container MUST declare explicit `aspect-ratio` or reserved layout dimensions prior to asset hydration.
   - Dynamic fonts must configure matching fallback font metric overrides (`ascent-override`, `descent-override`, `size-adjust`) to prevent font-swap layout shifts.
3. Frame Budget & Telemetry Observer:
   - Implement real-time FPS and long-task telemetry monitoring to proactively detect paint bottlenecks (>16.6ms).

## 2. Production Implementation

### Complete Tailwind v4 Theme & Base Tokens (`tailwind-v4-theme.css`)

```css
@import "tailwindcss";

@theme {
  /* OKLCH Perceptual Spectrum */
  --color-ground-0: oklch(0.10 0.015 250);
  --color-ground-1: oklch(0.12 0.015 250);
  --color-ground-2: oklch(0.15 0.020 250);
  
  --color-surface-slab: oklch(0.18 0.022 250 / 0.75);
  --color-surface-active: oklch(0.22 0.028 250 / 0.90);

  --color-accent-solar: oklch(0.85 0.18 85);
  --color-accent-emerald: oklch(0.88 0.19 145);
  --color-accent-cyan: oklch(0.82 0.14 200);

  /* Directional Specular Hairlines */
  --shadow-hairline: inset 0 1px 0 0 oklch(1 0 0 / 0.18), inset 0 0 0 1px oklch(1 0 0 / 0.06);
  --shadow-elevated: inset 0 1px 0 0 oklch(1 0 0 / 0.25), 0 24px 48px -12px oklch(0 0 0 / 0.6);

  /* Fluid Spacing Grid (4px Baseline) */
  --spacing-grid-xs: 0.25rem;  /* 4px */
  --spacing-grid-sm: 0.5rem;   /* 8px */
  --spacing-grid-md: 1rem;     /* 16px */
  --spacing-grid-lg: 1.5rem;   /* 24px */
  --spacing-grid-xl: 2rem;     /* 32px */
  --spacing-grid-2xl: 4rem;    /* 64px */
}

@layer utilities {
  .text-tabular {
    font-variant-numeric: tabular-nums;
    font-feature-settings: "tnum";
  }

  .gpu-layer {
    transform: translateZ(0);
    will-change: transform;
    backface-visibility: hidden;
  }
}
```

### Telemetry Performance Harness Hook (`usePerformanceTelemetry.ts`)

```ts
import { useEffect, useState } from "react";

export interface TelemetryReport {
  fps: number;
  frameTime: number;
  memoryUsageMb: number | null;
  status: "OPTIMAL" | "DEGRADED" | "CRITICAL";
}

export function usePerformanceTelemetry(): TelemetryReport {
  const [report, setReport] = useState<TelemetryReport>({
    fps: 60,
    frameTime: 16.6,
    memoryUsageMb: null,
    status: "OPTIMAL",
  });

  useEffect(() => {
    let frameCount = 0;
    let lastTime = performance.now();
    let rafId: number;

    const tick = (now: number) => {
      frameCount++;
      const elapsed = now - lastTime;

      if (elapsed >= 1000) {
        const currentFps = Math.round((frameCount * 1000) / elapsed);
        const avgFrameTime = Number((elapsed / frameCount).toFixed(2));
        
        let memory: number | null = null;
        if ("memory" in performance) {
          const perfMem = (performance as unknown as { memory: { usedJSHeapSize: number } }).memory;
          memory = Number((perfMem.usedJSHeapSize / (1024 * 1024)).toFixed(1));
        }

        const status: TelemetryReport["status"] =
          currentFps >= 55 ? "OPTIMAL" : currentFps >= 40 ? "DEGRADED" : "CRITICAL";

        setReport({
          fps: currentFps,
          frameTime: avgFrameTime,
          memoryUsageMb: memory,
          status,
        });

        frameCount = 0;
        lastTime = now;
      }

      rafId = requestAnimationFrame(tick);
    };

    rafId = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(rafId);
  }, []);

  return report;
}
```

## 3. Prohibited Anti-Patterns

- Prohibited: Injecting CSS-in-JS style tags (styled-components or Emotion) on every frame render tick.
- Prohibited: Images, videos, or 3D canvases placed without `aspect-ratio` or fixed height, inducing visual page jump (CLS > 0).
- Prohibited: Relying on `!important` flags across CSS declarations to override weak specificity.
- Prohibited: Leaving memory or performance observers running without cleanup upon component unmounting.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-PRF-001 (Ubiquitous): The design system SHALL specify all design tokens inside native CSS custom properties without JS runtime costs.
- REQ-PRF-002 (Ubiquitous): Every visual container SHALL declare an immutable aspect-ratio preventing layout shift (CLS = 0.000).
- REQ-PRF-003 (State-Driven): WHILE running on desktop browsers, the rendering loop SHALL maintain continuous 60 FPS (under 16.6ms frame time).
- REQ-PRF-004 (Unwanted Behavior): IF average frame time exceeds 24ms over 2 consecutive reporting intervals, THEN the telemetry hook SHALL emit a "DEGRADED" system alert.
