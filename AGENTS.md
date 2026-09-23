# AGENTS.md - Anti-Slop Webcraft Operational Charter

## System Identity & Objective
This repository contains the Anti-Slop Webcraft Skill Engine. It establishes non-negotiable frontend engineering and aesthetic invariants for autonomous AI coding agents (Claude Code, Cursor, Antigravity, Hermes). Agents consuming this repository must construct museum-grade, high-density, physically grounded interfaces without aesthetic degradation or generic AI patterns.

## Non-Negotiable Invariants
1. Color Architecture:
   - Absolute ban on generic AI purple/indigo (`#6366f1`, hues 255-280 deg) and warm cream (`#faf8f5`) + forest green combinations.
   - Enforce OKLCH 60-30-10 distribution: 60% dominant base ground, 30% structural surface contrast (frosted glass slabs with physical 1px hairline borders), 10% intentional high-contrast accent.
   - Physicality: True physical transmission (`backdrop-filter: blur(24px) saturate(160%)`), directional inner specular highlights (`box-shadow: inset 0 1px 0 0 oklch(1 0 0 / 0.2)`), zero unprompted blurry drop-shadows.
2. Typography & Iconography:
   - Absolute ban on Inter defaults and unprompted clichéd triads (Space Grotesk + Instrument Serif + Geist).
   - Engineered dual-pairing: Distinct grotesque display font + high-contrast monospace/tabular font for telemetry.
   - Absolute ban on unicode emojis in UI, code, comments, and commit messages. Use `@phosphor-icons/react` (`stroke-width="1.5"`) or inline SVG paths.
3. Motion & Physics:
   - Spring dynamics over arbitrary ease curves (`type: "spring", stiffness: 200, damping: 25`).
   - Hardware acceleration: GPU layering (`transform: translateZ(0)`, `will-change: transform`).
   - Scrub synchronization: Smooth scroll integration (Lenis) with GSAP ScrollTrigger timelines.

## Directory & Skill Map (24 Production Modules)
- `.skills/core/`
  - `01-anti-slop-design-system.md`: OKLCH tokens, 4px baseline, anti-cliché blacklists.
  - `02-typography-and-tabular-grid.md`: Asymmetric layouts, fluid type math, zero-emoji protocol.
- `.skills/3d-and-shaders/`
  - `03-r3f-glass-and-materials.md`: Physical refraction, liquid metal, IOR 1.52, chromatic aberration.
  - `04-custom-glsl-backgrounds.md`: Perlin/Simplex noise, raymarched volumetric fields, grain passes.
  - `05-interactive-3d-mockups.md`: OrbitControls damping, spring cursor tilts, floating HUDs.
  - `14-audio-reactive-and-spectrum-shaders.md`: Web Audio FFT analyzer, GLSL waveform shaders.
  - `18-webgl-particle-fields-and-simulations.md`: GPGPU particle physics, curl noise simulations.
- `.skills/motion-and-cinematics/`
  - `06-gsap-scroll-trigger-mastery.md`: Pinned stages, scrub mathematics, Lenis synchronization.
  - `07-framer-motion-physics.md`: Spring physics, magnetic buttons, spotlight cards.
  - `08-text-kinetic-animations.md`: Character splitting, velocity-based skewing, tabular tickers.
  - `19-infinite-smooth-marquee-and-carousel.md`: GPU-only infinite translation marquee, hover damping.
- `.skills/media-and-vectors/`
  - `09-bespoke-svg-and-vector-physics.md`: Pure SVG math, stroke calibrations, hairline paths.
  - `10-canvas-video-transduction.md`: Seamless canvas loops, alpha WebM, scroll scrubbing.
  - `13-animated-beam-and-connection-graphs.md`: Curvature SVG connection beams, bezier pulse physics.
- `.skills/components-and-primitives/`
  - `11-bento-grid-and-spatial-slabs.md`: Asymmetric Bento grids, animated border beam sweeps.
  - `12-interactive-dock-and-liquid-tabs.md`: macOS dock proximity magnification, spring liquid tabs.
  - `21-fluid-drawer-and-bottom-sheet.md`: iOS-native fluid drag sheet, spring snap points.
  - `22-dynamic-island-and-morphing-nav.md`: Apple dynamic island, morphing status pill.
  - `25-ecosystem-crawling-and-component-transduction.md`: Component ecosystem crawling & transduction pipeline.
- `.skills/micro-interactions-and-tactile/`
  - `15-pixel-perfection-and-retro-grids.md`: 2D canvas pixel cards, retro horizon perspective grids.
  - `16-magnetic-cursor-and-optical-lenses.md`: Custom optical cursor lens, difference blend modes.
  - `17-scramble-and-matrix-decoding-text.md`: Cybernetic text scrambler, entropy progressive decoding.
  - `23-command-palette-and-spotlight-hud.md`: Linear/Raycast keyboard spotlight, fuzzy score dialog.
  - `24-shimmer-skeleton-and-layout-reveals.md`: Zero CLS specular shimmer, progressive layout reveals.
- `.skills/state-and-performance/`
  - `20-zero-runtime-css-and-tailwind-v4-optimization.md`: Tailwind v4 theme, CLS=0, telemetry harness.

## Standard Commands & Shell Primitives
- Install skills into any project: `npx anti-slop-webcraft init`
- Audit project for AI slop: `npx anti-slop-webcraft verify`
- List all 24 skills: `npx anti-slop-webcraft list`
- Package management: `pnpm install` (preferred) or `npm install`
- Local dev server: `pnpm run dev` or `npm run dev`
- Production build: `pnpm run build` or `npm run build`

## Agent Execution Rules
- Before writing any UI component, load the targeted module from `.skills/` into context.
- Never output generic placeholder content ("Lorem ipsum", "Coming soon", "Card Title").
- Adhere to EARS syntax for functional requirements when generating specifications.
