# Skill 06: GSAP ScrollTrigger Mastery, Pinned Stages & Lenis Sync

## 1. System Invariants

1. Frictionless Smooth Scroll Synchronization:
   - Synchronize GSAP ScrollTrigger with Lenis smooth scroll using `lenis.on('scroll', ScrollTrigger.update)`.
   - Pipe GSAP ticker to Lenis: `gsap.ticker.add((time) => lenis.raf(time * 1000)); gsap.ticker.lagSmoothing(0);`.
2. Lifecycle Memory Integrity:
   - Always encapsulate all GSAP animations within `gsap.context()` in React/Next.js components.
   - Execute `ctx.revert()` unconditionally in cleanup routines to prevent memory leaks and ghost triggers.
3. Scrub Mathematics & Physical Snapping:
   - Standardize on numeric scrub values (`scrub: 1` or `scrub: 1.5`) rather than boolean `scrub: true` to inject physical momentum and eliminate abrupt stops.
   - Use `pinSpacing: true` on pinned stages to avoid content overlaps unless explicit multi-layer stacking is required.
4. Responsive Timeline Calibration:
   - Wrap pinned timelines in `gsap.matchMedia()` to disable pinning or modify scrub coordinates gracefully on mobile viewports.

## 2. Production Implementation

### Cinematic Pinned Scrollytelling Stage (`PinnedScrollytelling.tsx`)

```tsx
import React, { useLayoutEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

interface PhaseData {
  id: string;
  step: string;
  title: string;
  telemetry: string;
}

const PHASES: PhaseData[] = [
  { id: "01", step: "PHASE_01", title: "KINETIC INGESTION", telemetry: "THROUGHPUT: 12.4 GB/S" },
  { id: "02", step: "PHASE_02", title: "OPTICAL REFRACTION", telemetry: "DISPERSION: 0.05 IOR" },
  { id: "03", step: "PHASE_03", title: "AUTONOMOUS DEPLOY", telemetry: "VERIFIED ZERO-SLOP" },
];

export const PinnedScrollytelling: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null!);
  const cardsRef = useRef<HTMLDivElement[]>([]);

  useLayoutEffect(() => {
    const ctx = gsap.context(() => {
      const mm = gsap.matchMedia();

      mm.add("(min-width: 768px)", () => {
        const totalPhases = PHASES.length;
        const tl = gsap.timeline({
          scrollTrigger: {
            trigger: containerRef.current,
            start: "top top",
            end: `+=${totalPhases * 100}%`,
            pin: true,
            scrub: 1.2,
            anticipatePin: 1,
          },
        });

        // Staggered card peeling and transformation choreography
        cardsRef.current.forEach((card, index) => {
          if (index === 0) return; // First card is resting state

          tl.fromTo(
            card,
            { yPercent: 120, opacity: 0, scale: 0.9, rotateX: -10 },
            {
              yPercent: 0,
              opacity: 1,
              scale: 1,
              rotateX: 0,
              duration: 1,
              ease: "power2.out",
            },
            `step-${index}`
          );

          // Deepen preceding card in z-space
          tl.to(
            cardsRef.current[index - 1],
            { scale: 0.92, opacity: 0.4, filter: "blur(8px)", duration: 1 },
            `step-${index}`
          );
        });
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  return (
    <section
      ref={containerRef}
      className="relative flex h-screen w-full items-center justify-center overflow-hidden bg-[oklch(0.12_0.015_250)] px-6"
    >
      <div className="relative h-[480px] w-full max-w-3xl">
        {PHASES.map((phase, i) => (
          <div
            key={phase.id}
            ref={(el) => {
              if (el) cardsRef.current[i] = el;
            }}
            className="absolute inset-0 flex flex-col justify-between rounded-2xl border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.16_0.02_250)] p-8 shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.2)] backdrop-blur-2xl"
            style={{ zIndex: i + 1 }}
          >
            <div className="flex items-center justify-between border-b border-[oklch(1_0_0_/_0.06)] pb-4">
              <span className="font-mono text-xs uppercase tracking-widest text-[oklch(0.85_0.18_85)]">
                {phase.step}
              </span>
              <span className="font-mono text-[11px] tabular-nums text-[oklch(0.55_0.02_250)]">
                {phase.telemetry}
              </span>
            </div>

            <div className="my-auto">
              <h2 className="font-['Clash_Display'] text-4xl font-bold tracking-tight text-[oklch(0.96_0.01_250)] md:text-5xl">
                {phase.title}
              </h2>
            </div>

            <div className="flex items-center justify-between border-t border-[oklch(1_0_0_/_0.06)] pt-4 font-mono text-[10px] text-[oklch(0.45_0.02_250)]">
              <span>INDEX: 0{i + 1} / 03</span>
              <span>ENGINE: GSAP_SCROLLTRIGGER</span>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Running GSAP ScrollTrigger alongside smooth scrolling without ticker lag synchronization, resulting in visual jitter.
- Prohibited: Omitting `ctx.revert()` in React `useEffect` or `useLayoutEffect`, causing duplicate pin wrappers upon hot reloads.
- Prohibited: Using `scrub: true` without momentum damping, which causes harsh, jarring stops on trackpad release.
- Prohibited: Hardcoded pixel pin distances (`end: "+=3000"`) that break across variable screen resolutions.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-GSAP-001 (Ubiquitous): All ScrollTrigger instances SHALL be encapsulated in `gsap.context()` and fully disposed on component unmount.
- REQ-GSAP-002 (Ubiquitous): Scrub timelines SHALL apply numeric damping (`scrub >= 1.0`) to emulate physical mass and momentum.
- REQ-GSAP-003 (State-Driven): WHILE on screens narrower than 768px, the layout SHALL automatically dissolve pinned card stacks into fluid static sections via `gsap.matchMedia()`.
- REQ-GSAP-004 (Unwanted Behavior): IF the user scrolls at high velocity, THEN pin release SHALL not cause layout snapping or visual blanking.
