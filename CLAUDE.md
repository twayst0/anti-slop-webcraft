# CLAUDE.md - Anti-Slop Webcraft Guidelines for Claude Code

## Project Overview
The Anti-Slop Webcraft Skill Engine provides 24 modular, production-tested architectural guides and code templates for building museum-grade, Awwwards Site of the Year tier web applications.

## Critical Invariants (Anti-Slop Enforcement)
- Color Space: Exclusively OKLCH tokens. Strict 60% ground, 30% structural surface, 10% high-contrast accent. No generic purple `#6366f1` or cream/forest green tropes.
- Glass & Surfaces: True physical transmission (`backdrop-filter: blur(24px) saturate(160%)`), 1px hairline specular borders (`inset 0 1px 0 0 oklch(1 0 0 / 0.2)`).
- Typography: Engineered dual-pairing (Grotesque display + Monospace telemetry). Always set `font-variant-numeric: tabular-nums` for numeric indicators.
- Iconography: Absolute ban on unicode emojis. Use `@phosphor-icons/react` (stroke 1.5) or bespoke SVG vectors.
- Motion: Physics-first spring configurations (`type: "spring", stiffness: 200, damping: 25`). Avoid linear and generic cubic bezier easings.
- 3D/Shaders: MeshTransmissionMaterial, IOR 1.52, chromatic aberration, HDR environment maps, and GPU acceleration (`transform: translateZ(0)`).

## 24-Skill Module Catalog
- Core: `.skills/core/01-anti-slop-design-system.md`, `.skills/core/02-typography-and-tabular-grid.md`
- 3D & Shaders: `.skills/3d-and-shaders/03-r3f-glass-and-materials.md`, `.skills/3d-and-shaders/04-custom-glsl-backgrounds.md`, `.skills/3d-and-shaders/05-interactive-3d-mockups.md`, `.skills/3d-and-shaders/14-audio-reactive-and-spectrum-shaders.md`, `.skills/3d-and-shaders/18-webgl-particle-fields-and-simulations.md`
- Motion & Cinematics: `.skills/motion-and-cinematics/06-gsap-scroll-trigger-mastery.md`, `.skills/motion-and-cinematics/07-framer-motion-physics.md`, `.skills/motion-and-cinematics/08-text-kinetic-animations.md`, `.skills/motion-and-cinematics/19-infinite-smooth-marquee-and-carousel.md`
- Media & Vectors: `.skills/media-and-vectors/09-bespoke-svg-and-vector-physics.md`, `.skills/media-and-vectors/10-canvas-video-transduction.md`, `.skills/media-and-vectors/13-animated-beam-and-connection-graphs.md`
- Components (Mobbin UI Max Pro): `.skills/components-and-primitives/11-bento-grid-and-spatial-slabs.md`, `.skills/components-and-primitives/12-interactive-dock-and-liquid-tabs.md`, `.skills/components-and-primitives/21-fluid-drawer-and-bottom-sheet.md`, `.skills/components-and-primitives/22-dynamic-island-and-morphing-nav.md`, `.skills/components-and-primitives/25-ecosystem-crawling-and-component-transduction.md`
- Micro-Interactions: `.skills/micro-interactions-and-tactile/15-pixel-perfection-and-retro-grids.md`, `.skills/micro-interactions-and-tactile/16-magnetic-cursor-and-optical-lenses.md`, `.skills/micro-interactions-and-tactile/17-scramble-and-matrix-decoding-text.md`, `.skills/micro-interactions-and-tactile/23-command-palette-and-spotlight-hud.md`, `.skills/micro-interactions-and-tactile/24-shimmer-skeleton-and-layout-reveals.md`
- State & Performance: `.skills/state-and-performance/20-zero-runtime-css-and-tailwind-v4-optimization.md`

## CLI Commands
```bash
# Inject skills into project
node bin/cli.js init

# Audit project for AI slop
node bin/cli.js verify

# List all skills
node bin/cli.js list
```
