#!/usr/bin/env bash
set -e

REPO_RAW="https://raw.githubusercontent.com/twayst0/anti-slop-webcraft/main"
TARGET_DIR="${1:-.}"

echo "==================================================================="
echo "  ANTI-SLOP WEBCRAFT SKILL ENGINE INSTALLER (UNIX/MACOS)"
echo "  Deploying museum-grade frontend engineering skills to AI agents"
echo "==================================================================="

mkdir -p "$TARGET_DIR/.skills/core"
mkdir -p "$TARGET_DIR/.skills/3d-and-shaders"
mkdir -p "$TARGET_DIR/.skills/motion-and-cinematics"
mkdir -p "$TARGET_DIR/.skills/media-and-vectors"
mkdir -p "$TARGET_DIR/.skills/components-and-primitives"
mkdir -p "$TARGET_DIR/.skills/micro-interactions-and-tactile"
mkdir -p "$TARGET_DIR/.skills/state-and-performance"

echo "[1/3] Downloading agent governance charters..."
curl -fsSL "$REPO_RAW/.cursorrules" -o "$TARGET_DIR/.cursorrules"
curl -fsSL "$REPO_RAW/AGENTS.md" -o "$TARGET_DIR/AGENTS.md"
curl -fsSL "$REPO_RAW/CLAUDE.md" -o "$TARGET_DIR/CLAUDE.md"

echo "[2/3] Downloading 24-skill documentation suite..."

SKILLS=(
  "core/01-anti-slop-design-system.md"
  "core/02-typography-and-tabular-grid.md"
  "3d-and-shaders/03-r3f-glass-and-materials.md"
  "3d-and-shaders/04-custom-glsl-backgrounds.md"
  "3d-and-shaders/05-interactive-3d-mockups.md"
  "motion-and-cinematics/06-gsap-scroll-trigger-mastery.md"
  "motion-and-cinematics/07-framer-motion-physics.md"
  "motion-and-cinematics/08-text-kinetic-animations.md"
  "media-and-vectors/09-bespoke-svg-and-vector-physics.md"
  "media-and-vectors/10-canvas-video-transduction.md"
  "components-and-primitives/11-bento-grid-and-spatial-slabs.md"
  "components-and-primitives/12-interactive-dock-and-liquid-tabs.md"
  "media-and-vectors/13-animated-beam-and-connection-graphs.md"
  "3d-and-shaders/14-audio-reactive-and-spectrum-shaders.md"
  "micro-interactions-and-tactile/15-pixel-perfection-and-retro-grids.md"
  "micro-interactions-and-tactile/16-magnetic-cursor-and-optical-lenses.md"
  "micro-interactions-and-tactile/17-scramble-and-matrix-decoding-text.md"
  "3d-and-shaders/18-webgl-particle-fields-and-simulations.md"
  "motion-and-cinematics/19-infinite-smooth-marquee-and-carousel.md"
  "state-and-performance/20-zero-runtime-css-and-tailwind-v4-optimization.md"
  "components-and-primitives/21-fluid-drawer-and-bottom-sheet.md"
  "components-and-primitives/22-dynamic-island-and-morphing-nav.md"
  "micro-interactions-and-tactile/23-command-palette-and-spotlight-hud.md"
  "micro-interactions-and-tactile/24-shimmer-skeleton-and-layout-reveals.md"
  "components-and-primitives/25-ecosystem-crawling-and-component-transduction.md"
)

for skill in "${SKILLS[@]}"; do
  echo "  + Downloading .skills/$skill..."
  curl -fsSL "$REPO_RAW/.skills/$skill" -o "$TARGET_DIR/.skills/$skill"
done

echo "[3/3] Installation completed successfully!"
echo "AI agents in this directory are now configured with Anti-Slop Webcraft."
