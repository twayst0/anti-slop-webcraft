# Anti-Slop Webcraft Skill Engine

> The definitive, museum-grade webcraft specification, 25-module skill engine, and autonomous CLI installer designed to empower AI coding agents (Cursor, Claude Code, Antigravity, Hermes) to construct high-density, physically grounded, non-generic web applications without aesthetic degradation.

---

## Quickstart & Installation Manual

Deploy the full 25-skill suite and agent governance rules into any existing or new web project in seconds:

### Method 1: Instant NPX CLI (Recommended)
```bash
# In your project root:
npx anti-slop-webcraft init
```
This automatically inspects your project root, creates `.skills/`, and injects `.cursorrules`, `AGENTS.md`, and `CLAUDE.md`.

### Method 2: Windows PowerShell
```powershell
powershell -c "irm https://raw.githubusercontent.com/twayst0/anti-slop-webcraft/main/install.ps1 | iex"
```

### Method 3: Unix / macOS Terminal
```bash
curl -fsSL https://raw.githubusercontent.com/twayst0/anti-slop-webcraft/main/install.sh | bash
```

---

## Agent Ingestion & IDE Configuration Guide

### 1. Cursor IDE Integration
1. Run `npx anti-slop-webcraft init` in your project root.
2. Confirm `.cursorrules` exists in your project root.
3. Cursor automatically reads the routing table. When you prompt Cursor for a feature (e.g., *"Build a responsive telemetry dashboard"*), Cursor loads `.skills/core/01-anti-slop-design-system.md` and `.skills/components-and-primitives/11-bento-grid-and-spatial-slabs.md` to construct physical, non-generic components.

### 2. Claude Code Integration
1. Ensure `CLAUDE.md` and `.skills/` are present in your workspace root.
2. Direct Claude Code to consult specific modules on demand:
   ```bash
   claude "Review .skills/components-and-primitives/21-fluid-drawer-and-bottom-sheet.md and implement the iOS fluid bottom drawer"
   ```

### 3. Google Antigravity Integration
1. Ensure `.skills/` and `AGENTS.md` are situated in your workspace root.
2. Antigravity discovers workspace agent charters and enforces OKLCH color palettes, spring physics, and zero-emoji mandates automatically.

### 4. Framework Setup (Next.js & Vite)

#### Installing Required Creative Dependencies
```bash
# Core Physics & Animation
pnpm add framer-motion gsap @phosphor-icons/react lenis

# 3D, WebGL & Shaders (Optional for 3D modules)
pnpm add three @react-three/fiber @react-three/drei
pnpm add -D @types/three
```

#### Tailwind CSS v4 OKLCH Configuration (`globals.css`)
Add the physical design system tokens to your root stylesheet:
```css
@import "tailwindcss";

@theme {
  --color-ground-base: oklch(0.12 0.015 250);
  --color-ground-subtle: oklch(0.15 0.018 250);
  --color-surface-panel: oklch(0.18 0.022 250 / 0.75);
  --color-surface-active: oklch(0.22 0.028 250 / 0.90);

  --color-accent-primary: oklch(0.85 0.18 85);
  --color-accent-emerald: oklch(0.88 0.19 145);
  --color-accent-cyan: oklch(0.82 0.14 200);

  --shadow-specular: inset 0 1px 0 0 oklch(1 0 0 / 0.2), inset 0 0 0 1px oklch(1 0 0 / 0.06);
}
```

---

## The 25-Skill Architecture Matrix

| Module ID | Skill File | Domain & Architectural Pattern | Context Budget |
| :--- | :--- | :--- | :--- |
| `SKILL-01` | `.skills/core/01-anti-slop-design-system.md` | OKLCH 60-30-10 & Physical Surface Engine | < 2,500 tokens |
| `SKILL-02` | `.skills/core/02-typography-and-tabular-grid.md` | Dual-Pairing & Tabular Numeric Telemetry | < 2,800 tokens |
| `SKILL-03` | `.skills/3d-and-shaders/03-r3f-glass-and-materials.md` | R3F MeshTransmission (IOR 1.52) & Liquid Metal | < 3,200 tokens |
| `SKILL-04` | `.skills/3d-and-shaders/04-custom-glsl-backgrounds.md` | Fullscreen WebGL Simplex Noise & Filmic Grain | < 3,000 tokens |
| `SKILL-05` | `.skills/3d-and-shaders/05-interactive-3d-mockups.md` | Reactive 3D Chassis Tilt & Spatial HTML HUDs | < 2,900 tokens |
| `SKILL-06` | `.skills/motion-and-cinematics/06-gsap-scroll-trigger-mastery.md` | GSAP ScrollTrigger & Lenis Scrub Choreography | < 3,100 tokens |
| `SKILL-07` | `.skills/motion-and-cinematics/07-framer-motion-physics.md` | Second-Order Springs & Cursor Spotlights | < 2,700 tokens |
| `SKILL-08` | `.skills/motion-and-cinematics/08-text-kinetic-animations.md` | Accessible Split-Text & Tabular Number Tickers | < 2,600 tokens |
| `SKILL-09` | `.skills/media-and-vectors/09-bespoke-svg-and-vector-physics.md` | Hairline Vector Paths & Kinetic Oscilloscopes | < 2,500 tokens |
| `SKILL-10` | `.skills/media-and-vectors/10-canvas-video-transduction.md` | 60 FPS HTML5 Canvas Scroll Video Scrubber | < 2,800 tokens |
| `SKILL-11` | `.skills/components-and-primitives/11-bento-grid-and-spatial-slabs.md` | Asymmetric Bento Slabs & Animated Border Beams | < 2,900 tokens |
| `SKILL-12` | `.skills/components-and-primitives/12-interactive-dock-and-liquid-tabs.md` | macOS Proximity Magnification & Liquid Tabs | < 2,700 tokens |
| `SKILL-13` | `.skills/media-and-vectors/13-animated-beam-and-connection-graphs.md` | Dynamic Cubic Bezier SVG Connection Beams | < 2,800 tokens |
| `SKILL-14` | `.skills/3d-and-shaders/14-audio-reactive-and-spectrum-shaders.md` | Web Audio API FFT Spectrum & Waveform Shaders | < 3,200 tokens |
| `SKILL-15` | `.skills/micro-interactions-and-tactile/15-pixel-perfection-and-retro-grids.md` | Canvas Pixel Cards & Phosphorescent Trails | < 2,800 tokens |
| `SKILL-16` | `.skills/micro-interactions-and-tactile/16-magnetic-cursor-and-optical-lenses.md` | Fluid Magnetic Cursor & Optical Lens Difference | < 2,400 tokens |
| `SKILL-17` | `.skills/micro-interactions-and-tactile/17-scramble-and-matrix-decoding-text.md` | Cybernetic Progressive Entropy Text Decoders | < 2,500 tokens |
| `SKILL-18` | `.skills/3d-and-shaders/18-webgl-particle-fields-and-simulations.md` | 40,000+ GPU Particle Sim & Curl Noise Velocity | < 3,300 tokens |
| `SKILL-19` | `.skills/motion-and-cinematics/19-infinite-smooth-marquee-and-carousel.md` | Hardware-Accelerated Infinite Marquee Tracks | < 2,600 tokens |
| `SKILL-20` | `.skills/state-and-performance/20-zero-runtime-css-and-tailwind-v4-optimization.md` | Tailwind v4 Architecture, CLS=0 & Telemetry | < 2,500 tokens |
| `SKILL-21` | `.skills/components-and-primitives/21-fluid-drawer-and-bottom-sheet.md` | iOS-Native Fluid Drag Sheet & Velocity Dismiss | < 2,700 tokens |
| `SKILL-22` | `.skills/components-and-primitives/22-dynamic-island-and-morphing-nav.md` | Apple Dynamic Island & Morphing Navigation Pill | < 2,600 tokens |
| `SKILL-23` | `.skills/micro-interactions-and-tactile/23-command-palette-and-spotlight-hud.md` | Keyboard Command Palette & Telemetry Spotlight | < 2,800 tokens |
| `SKILL-24` | `.skills/micro-interactions-and-tactile/24-shimmer-skeleton-and-layout-reveals.md` | Zero-CLS Directional Shimmer Skeletons | < 2,600 tokens |
| `SKILL-25` | `.skills/components-and-primitives/25-ecosystem-crawling-and-component-transduction.md` | Component Ecosystem Crawling & Anti-Slop Pipeline | < 2,700 tokens |

---

## Executive Manifesto: Ending AI Frontend Slop

AI code generation has converged toward an uninspired monoculture:
- Indiscriminate use of generic purple/indigo gradients (`#6366f1` / hues 255-280 deg).
- Overused "warm cream" (`#faf8f5`) canvases hastily paired with forest green and serif accents.
- Monotonous Inter default typography devoid of character, rhythm, or friction.
- Excessive, unprompted unicode emojis masquerading as iconography.
- Floppy, linear CSS animations disconnected from mechanical or physical reality.
- Heavy drop shadows without optical falloff or physical surface transmission.

The **Anti-Slop Webcraft Skill Engine** enforces architectural rigor, optical physics, fluid typography, and mathematical precision across every phase of frontend construction. Inspired by Mobbin UI Max, Awwwards Site of the Year honorees, and Apple Liquid Metal surfaces, it equips autonomous agents with production-ready invariants that reject generic templates.

---

## CLI Command Suite

```bash
# Inject skills, agent configs, and rules into current project
npx anti-slop-webcraft init

# Audit project code for generic AI purple, unicode emojis, or linear CSS easing
npx anti-slop-webcraft verify

# List all 24 skills with sizes and architectural categories
npx anti-slop-webcraft list

# Display help
npx anti-slop-webcraft help
```

---

## Governance & Authorship

- **Creator & Lead Architect**: [tways](https://github.com/twayst0)
- **Repository**: [twayst0/anti-slop-webcraft](https://github.com/twayst0/anti-slop-webcraft)
- **License**: Custom Commercial & Personal Permissive (See [LICENSE](LICENSE))
