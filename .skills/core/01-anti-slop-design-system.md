# Skill 01: Anti-Slop Design System & OKLCH Surface Engine

## 1. System Invariants

1. Color Model: Exclusively OKLCH color space. Never output legacy sRGB hex codes for primary UI tokens.
2. 60-30-10 Surface Hierarchy:
   - 60% Dominant Base: Deep, low-chroma perceptual ground (`oklch(0.12 0.015 250)`).
   - 30% Structural Glass/Slab: Elevated surfaces with physical transmission (`oklch(0.18 0.02 250 / 0.75)`), backdrop blur (`blur(24px) saturate(160%)`), and 1px directional hairline specular border.
   - 10% High-Contrast Accent: Directional, high-chroma accent (`oklch(0.85 0.18 85)` solar amber or `oklch(0.88 0.19 145)` laser emerald).
3. Specular Hairline Borders:
   - Use physical inner specular highlight: `box-shadow: inset 0 1px 0 0 oklch(1 0 0 / 0.18), inset 0 0 0 1px oklch(1 0 0 / 0.06)`.
   - Never apply blurry, unstructured drop shadows (`box-shadow: 0 10px 25px rgba(0,0,0,0.5)`).
4. Spacing Rhythm:
   - Strict 4px mathematical baseline grid (`4px`, `8px`, `12px`, `16px`, `24px`, `32px`, `48px`, `64px`, `96px`).

## 2. Production Implementation

### Tailwind CSS v4 Theme Configuration (`globals.css`)

```css
@theme {
  --color-ground-base: oklch(0.12 0.015 250);
  --color-ground-subtle: oklch(0.15 0.018 250);
  --color-surface-panel: oklch(0.18 0.022 250 / 0.72);
  --color-surface-hover: oklch(0.22 0.028 250 / 0.85);
  
  --color-border-hairline: oklch(1 0 0 / 0.08);
  --color-border-specular: oklch(1 0 0 / 0.22);
  
  --color-text-primary: oklch(0.96 0.01 250);
  --color-text-muted: oklch(0.65 0.02 250);
  --color-text-faint: oklch(0.42 0.02 250);

  --color-accent-primary: oklch(0.85 0.18 85);
  --color-accent-glow: oklch(0.85 0.18 85 / 0.15);
  --color-accent-cyan: oklch(0.82 0.14 200);

  --shadow-specular: inset 0 1px 0 0 oklch(1 0 0 / 0.2), inset 0 0 0 1px oklch(1 0 0 / 0.07);
  --shadow-elevated: 0 20px 40px -15px oklch(0 0 0 / 0.5), inset 0 1px 0 0 oklch(1 0 0 / 0.25);
}

@layer base {
  body {
    background-color: var(--color-ground-base);
    color: var(--color-text-primary);
    font-feature-settings: "cv02", "cv03", "cv04", "cv11";
    -webkit-font-smoothing: antialiased;
  }
}
```

### Production Glass Panel Component (`GlassPanel.tsx`)

```tsx
import React from "react";

interface GlassPanelProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode;
  variant?: "surface" | "interactive" | "accent";
  className?: string;
}

export const GlassPanel: React.FC<GlassPanelProps> = ({
  children,
  variant = "surface",
  className = "",
  ...props
}) => {
  const baseClasses =
    "relative overflow-hidden rounded-xl backdrop-blur-xl transition-all duration-200";

  const variantMap = {
    surface:
      "bg-[oklch(0.18_0.022_250_/_0.72)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.18),inset_0_0_0_1px_oklch(1_0_0_/_0.06)]",
    interactive:
      "bg-[oklch(0.18_0.022_250_/_0.72)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.18),inset_0_0_0_1px_oklch(1_0_0_/_0.06)] hover:bg-[oklch(0.22_0.028_250_/_0.85)] hover:shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.3),0_8px_24px_-8px_oklch(0_0_0_/_0.4)]",
    accent:
      "bg-[oklch(0.20_0.03_85_/_0.15)] shadow-[inset_0_1px_0_0_oklch(0.85_0.18_85_/_0.4),inset_0_0_0_1px_oklch(0.85_0.18_85_/_0.2)]",
  };

  return (
    <div
      className={`${baseClasses} ${variantMap[variant]} ${className}`}
      {...props}
    >
      <div
        className="pointer-events-none absolute -inset-px opacity-30 mix-blend-overlay"
        style={{
          backgroundImage:
            "radial-gradient(ellipse at 50% 0%, oklch(1 0 0 / 0.15) 0%, transparent 70%)",
        }}
        aria-hidden="true"
      />
      <div className="relative z-10">{children}</div>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Generic AI purple gradient `#6366f1` / `rgb(99, 102, 241)`.
- Prohibited: Second-generation aesthetic slop: warm cream `#faf8f5` canvas paired with dark forest green and classical serif fonts.
- Prohibited: Uncalibrated RGB/HEX opacity hacks such as `rgba(255, 255, 255, 0.05)` without perceptual luminance calibration.
- Prohibited: Blurry drop shadows with large spread and zero specular edge definition.
- Prohibited: Unicode emojis in place of functional icons.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-COL-001 (Ubiquitous): The design system SHALL specify all color primitives using OKLCH color notations with explicit lightness, chroma, and hue parameters.
- REQ-COL-002 (Ubiquitous): Every elevated glass surface SHALL feature a directional 1px inner specular highlight (`inset 0 1px 0 0`) with at least 15% perceived contrast over ground.
- REQ-COL-003 (State-Driven): WHILE a user hovers over an interactive panel, the component SHALL increase specular inner intensity without introducing layout shift or fuzzy drop shadows.
- REQ-COL-004 (Unwanted Behavior): IF an AI agent attempts to emit `#6366f1` or generic purple gradients, THEN the build process SHALL reject the style token and fall back to calibrated solar amber or laser emerald accents.
