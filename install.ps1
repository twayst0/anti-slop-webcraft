# Anti-Slop Webcraft Skill Engine Windows PowerShell Installer
$ErrorActionPreference = "Stop"

$RepoRaw = "https://raw.githubusercontent.com/twayst0/anti-slop-webcraft/main"
$TargetDir = if ($args[0]) { $args[0] } else { "." }

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  ANTI-SLOP WEBCRAFT SKILL ENGINE INSTALLER (WINDOWS POWERSHELL)" -ForegroundColor Cyan
Write-Host "  Deploying museum-grade frontend engineering skills to AI agents" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

$Folders = @(
  ".skills/core",
  ".skills/3d-and-shaders",
  ".skills/motion-and-cinematics",
  ".skills/media-and-vectors",
  ".skills/components-and-primitives",
  ".skills/micro-interactions-and-tactile",
  ".skills/state-and-performance"
)

foreach ($folder in $Folders) {
  $path = Join-Path $TargetDir $folder
  if (-not (Test-Path $path)) {
    New-Item -ItemType Directory -Path $path -Force | Out-Null
  }
}

Write-Host "[1/3] Downloading agent governance charters..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "$RepoRaw/.cursorrules" -OutFile (Join-Path $TargetDir ".cursorrules")
Invoke-RestMethod -Uri "$RepoRaw/AGENTS.md" -OutFile (Join-Path $TargetDir "AGENTS.md")
Invoke-RestMethod -Uri "$RepoRaw/CLAUDE.md" -OutFile (Join-Path $TargetDir "CLAUDE.md")

Write-Host "[2/3] Downloading 24-skill documentation suite..." -ForegroundColor Yellow

$Skills = @(
  "core/01-anti-slop-design-system.md",
  "core/02-typography-and-tabular-grid.md",
  "3d-and-shaders/03-r3f-glass-and-materials.md",
  "3d-and-shaders/04-custom-glsl-backgrounds.md",
  "3d-and-shaders/05-interactive-3d-mockups.md",
  "motion-and-cinematics/06-gsap-scroll-trigger-mastery.md",
  "motion-and-cinematics/07-framer-motion-physics.md",
  "motion-and-cinematics/08-text-kinetic-animations.md",
  "media-and-vectors/09-bespoke-svg-and-vector-physics.md",
  "media-and-vectors/10-canvas-video-transduction.md",
  "components-and-primitives/11-bento-grid-and-spatial-slabs.md",
  "components-and-primitives/12-interactive-dock-and-liquid-tabs.md",
  "media-and-vectors/13-animated-beam-and-connection-graphs.md",
  "3d-and-shaders/14-audio-reactive-and-spectrum-shaders.md",
  "micro-interactions-and-tactile/15-pixel-perfection-and-retro-grids.md",
  "micro-interactions-and-tactile/16-magnetic-cursor-and-optical-lenses.md",
  "micro-interactions-and-tactile/17-scramble-and-matrix-decoding-text.md",
  "3d-and-shaders/18-webgl-particle-fields-and-simulations.md",
  "motion-and-cinematics/19-infinite-smooth-marquee-and-carousel.md",
  "state-and-performance/20-zero-runtime-css-and-tailwind-v4-optimization.md",
  "components-and-primitives/21-fluid-drawer-and-bottom-sheet.md",
  "components-and-primitives/22-dynamic-island-and-morphing-nav.md",
  "micro-interactions-and-tactile/23-command-palette-and-spotlight-hud.md",
  "micro-interactions-and-tactile/24-shimmer-skeleton-and-layout-reveals.md",
  "components-and-primitives/25-ecosystem-crawling-and-component-transduction.md"
)

foreach ($skill in $Skills) {
  Write-Host "  + Downloading .skills/$skill..." -ForegroundColor Gray
  $dest = Join-Path $TargetDir ".skills/$skill"
  Invoke-RestMethod -Uri "$RepoRaw/.skills/$skill" -OutFile $dest
}

Write-Host "[3/3] Installation completed successfully!" -ForegroundColor Green
Write-Host "AI agents in this directory are now governed by Anti-Slop Webcraft." -ForegroundColor Green
