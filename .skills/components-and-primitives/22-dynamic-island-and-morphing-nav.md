# Skill 22: Apple Dynamic Island & Morphing Spatial Navigation Pills

## 1. System Invariants

1. Scroll-Bound Topology Morphing:
   - The navigation header MUST morph between two structural topologies based on window scroll threshold:
     - Top Tier (scrollY < 80px): Expansive full-width transparent header with lateral telemetry rails.
     - Scrolled Tier (scrollY >= 80px): Compact, floating pill centered in viewport with rounded-full geometry (`backdrop-filter: blur(20px)`).
2. Dynamic Island Expansion States:
   - The floating pill must expand dynamically (`layout` prop with second-order spring physics) to accommodate real-time alerts, audio playback waveforms, or system notices without unmounting the navigation bar.
3. Optical Elevation & Hairline Edge:
   - In floating state, the pill must declare `box-shadow: inset 0 1px 0 0 oklch(1 0 0 / 0.22), 0 12px 32px -8px oklch(0 0 0 / 0.5)`.

## 2. Production Implementation

### Morphing Dynamic Island Navigation (`DynamicIslandNav.tsx`)

```tsx
import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Activity, Bell, Cpu, ArrowUpRight, ShieldCheck } from "@phosphor-icons/react";

export const DynamicIslandNav: React.FC = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isExpanded, setIsExpanded] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 80);
    };
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <header className="fixed top-0 left-0 right-0 z-50 flex justify-center p-4">
      <motion.nav
        layout
        transition={{ type: "spring", stiffness: 380, damping: 30 }}
        className={`relative flex items-center justify-between border border-[oklch(1_0_0_/_0.12)] bg-[oklch(0.14_0.018_250_/_0.8)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.2)] backdrop-blur-2xl transition-colors ${
          isScrolled
            ? "h-12 rounded-full px-4 shadow-[0_16px_32px_-8px_oklch(0_0_0_/_0.6)]"
            : "h-16 w-full max-w-6xl rounded-2xl px-6"
        }`}
      >
        {/* Brand System */}
        <div className="flex items-center gap-3">
          <div className="flex h-7 w-7 items-center justify-center rounded-lg border border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.18_0.022_250)] text-[oklch(0.85_0.18_85)]">
            <Cpu size={16} weight="regular" />
          </div>
          <span className="font-['Clash_Display'] text-sm font-semibold tracking-tight text-[oklch(0.96_0.01_250)]">
            HYPERCRAFT
          </span>
        </div>

        {/* Dynamic Island Expansion Center Area */}
        <AnimatePresence>
          {isExpanded ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="flex items-center gap-4 px-3"
            >
              <div className="flex items-center gap-1.5 font-mono text-[10px] text-[oklch(0.88_0.19_145)]">
                <span className="h-1.5 w-1.5 rounded-full bg-[oklch(0.88_0.19_145)] animate-pulse" />
                <span>FFT_AUDIO_ACTIVE [48 KHZ]</span>
              </div>
              <button
                onClick={() => setIsExpanded(false)}
                className="font-mono text-[9px] uppercase tracking-wider text-[oklch(0.55_0.02_250)] hover:text-[oklch(0.85_0.01_250)]"
              >
                COLLAPSE
              </button>
            </motion.div>
          ) : (
            <div className="hidden md:flex items-center gap-6">
              <a href="#skills" className="font-mono text-xs uppercase tracking-wider text-[oklch(0.65_0.02_250)] transition-colors hover:text-[oklch(0.96_0.01_250)]">
                SPECIFICATION
              </a>
              <a href="#showcase" className="font-mono text-xs uppercase tracking-wider text-[oklch(0.65_0.02_250)] transition-colors hover:text-[oklch(0.96_0.01_250)]">
                TELEMETRY
              </a>
              <a href="#pipeline" className="font-mono text-xs uppercase tracking-wider text-[oklch(0.65_0.02_250)] transition-colors hover:text-[oklch(0.96_0.01_250)]">
                PIPELINE
              </a>
            </div>
          )}
        </AnimatePresence>

        {/* Action Trigger Rail */}
        <div className="flex items-center gap-2">
          {!isExpanded && (
            <button
              onClick={() => setIsExpanded(true)}
              className="flex h-7 items-center gap-1.5 rounded-full border border-[oklch(0.85_0.18_85_/_0.3)] bg-[oklch(0.85_0.18_85_/_0.1)] px-3 font-mono text-[10px] uppercase tracking-wider text-[oklch(0.85_0.18_85)] hover:bg-[oklch(0.85_0.18_85_/_0.2)]"
            >
              <Activity size={12} weight="bold" />
              <span className="hidden sm:inline">PULSE</span>
            </button>
          )}

          <a
            href="https://github.com/twayst0/anti-slop-webcraft"
            target="_blank"
            rel="noreferrer"
            className="flex h-7 w-7 items-center justify-center rounded-full border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.18_0.022_250)] text-[oklch(0.65_0.02_250)] transition-colors hover:text-[oklch(0.96_0.01_250)]"
          >
            <ArrowUpRight size={14} weight="bold" />
          </a>
        </div>
      </motion.nav>
    </header>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Abrupt swapping between two completely un-animated DOM navbars upon scroll threshold.
- Prohibited: Sticky headers that block 20% of vertical screen height permanently on mobile viewports.
- Prohibited: Animating `width` and `height` via CSS transitions without Framer Motion `layout` GPU composition.
- Prohibited: Missing backdrop blur filter, rendering text illegible over underlying page content.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-ISL-001 (Ubiquitous): The navigation chassis SHALL transition between full-width banner and floating pill states using continuous layout spring physics.
- REQ-ISL-002 (Ubiquitous): In floating state, the pill SHALL remain fixed at screen top with horizontal auto-centering.
- REQ-ISL-003 (State-Driven): WHILE dynamic status notifications fire, the island container SHALL expand horizontally to reveal telemetry payloads without layout jumps.
- REQ-ISL-004 (Unwanted Behavior): IF the user scrolls back to page origin, THEN the pill SHALL smoothly expand back into the un-docked header state.
