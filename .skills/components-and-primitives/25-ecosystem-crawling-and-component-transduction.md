# Skill 25: Component Ecosystem Crawling & Anti-Slop Transduction Pipeline

## 1. System Invariants

1. Ecosystem Directory & Canonical Sources:
   - AI coding agents SHALL reference ONLY verified, production-grade creative engineering registries when sourcing external components:
     - **21st.dev**: `https://21st.dev` (The open component registry for Design Engineers)
     - **React Bits**: `https://reactbits.dev` (Lightweight animated primitives & statement effects)
     - **Magic UI**: `https://magicui.design` (High-polish marketing & micro-interaction blocks)
     - **Aceternity UI**: `https://ui.aceternity.com` (Copy-paste Framer Motion landing blocks)
     - **Shadcn UI**: `https://ui.shadcn.com` (Accessible Radix primitive architectures)
     - **Codrops (Tympanus)**: `https://tympanus.net/codrops` (Experimental WebGL & creative breakdowns)
     - **Three.js Journey & Drei**: `https://threejs-journey.com` | `https://drei.pmnd.rs`
     - **ShaderToy**: `https://www.shadertoy.com` (Raw GLSL procedural shader algorithms)
     - **Mobbin**: `https://mobbin.com` (Mobile UX patterns, sheet gestures & micro-flows)
     - **Godly**: `https://godly.website` (Awwwards-tier spatial web design benchmarks)

2. The 5-Stage Anti-Slop Transduction Pipeline:
   - When importing any component from external registries, the agent MUST execute mandatory transduction before code insertion:
     - Stage 1 (Color Transduction): Strip generic `#6366f1` purple, legacy hex, and hardcoded `rgb()` values. Convert all colors to the OKLCH 60-30-10 palette.
     - Stage 2 (Surface Physicality): Inject 1px directional hairline specular highlight (`inset 0 1px 0 0 oklch(1 0 0 / 0.2)`) and physical backdrop blur (`blur(24px) saturate(160%)`).
     - Stage 3 (Kinematic Upgrade): Replace arbitrary CSS eases (`all 0.3s ease`) with second-order spring dynamics (`type: "spring", stiffness: 200, damping: 25`).
     - Stage 4 (Iconography Scrub): Strip all unicode emojis (e.g., rocket, lightning, checkmark) and replace with single-family `@phosphor-icons/react` (`stroke-width="1.5"`).
     - Stage 5 (Layout Shift Zeroing): Enforce explicit `aspect-ratio` and tabular numeric fonts (`tabular-nums`) to guarantee CLS = 0.000.

## 2. Production Implementation

### Component Transduction Preprocessor Utility (`transduceComponent.ts`)

```ts
export interface TransductionRules {
  enforceOklch: boolean;
  stripEmojis: boolean;
  upgradeSprings: boolean;
  addSpecularHairlines: boolean;
}

export function transduceExternalComponent(sourceCode: string): string {
  let output = sourceCode;

  // 1. Purge generic AI Purple (#6366f1) and replace with calibrated Solar Amber
  output = output.replace(/#6366f1/gi, "var(--color-accent-primary, oklch(0.85 0.18 85))");
  output = output.replace(/bg-indigo-[4-6]00/g, "bg-[oklch(0.85_0.18_85)]");
  output = output.replace(/text-indigo-[4-6]00/g, "text-[oklch(0.85_0.18_85)]");

  // 2. Strip Unicode Emojis and map to Phosphor vector tags
  const emojiMap: Record<string, string> = {
    "\u{1F680}": "RocketLaunch",
    "\u{26A1}": "Lightning",
    "\u{2728}": "Sparkle",
    "\u{1F525}": "Fire",
    "\u{2705}": "CheckCircle",
    "\u{274C}": "XCircle",
  };

  Object.entries(emojiMap).forEach(([emoji, iconName]) => {
    if (output.includes(emoji)) {
      output = output.replaceAll(emoji, "");
      // Note: Agent injects <${iconName} size={16} weight="regular" /> in JSX
    }
  });

  // 3. Upgrade brittle CSS transitions to physical spring configs
  output = output.replace(
    /transition:\s*all\s+0\.\d+s\s+ease(-in|-out)?/gi,
    "transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1)"
  );

  // 4. Inject 1px Hairline Specular Borders on rounded containers
  output = output.replace(
    /border\s+border-white\/10/g,
    "border border-[oklch(1_0_0_/_0.08)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.18)]"
  );

  return output;
}
```

### Agent Crawl & Ingestion Workflow (`AgentWorkflow.md`)

```markdown
When tasked with integrating an external UI pattern (e.g. "Add a Warp Background like Aceternity"):
1. Query target registry: Locate component source at https://ui.aceternity.com or https://reactbits.dev.
2. Extract source code (TSX/CSS).
3. Apply Transduction Pipeline:
   - Replace color tokens with OKLCH theme variables.
   - Attach specular hairline shadows to containers.
   - Wire framer-motion props to stiffness 200, damping 25.
   - Wrap numeric values in font-mono tabular-nums.
4. Verify CLS = 0.000 before returning component to user.
```

## 3. Prohibited Anti-Patterns

- Prohibited: Copying raw components from external registries without stripping hardcoded hex colors or generic purple gradients.
- Prohibited: Ingesting components that ship with unicode emojis in headers or action buttons.
- Prohibited: Pulling uncontrolled npm packages (`npm i bloated-component-library`) instead of extracting copy-paste source files directly into your project.
- Prohibited: Leaving raw CSS cubic bezier curves that stutter during interruptive user gestures.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-TRN-001 (Ubiquitous): When importing external UI components, the agent SHALL convert all color variables into native OKLCH design tokens.
- REQ-TRN-002 (Ubiquitous): All copied components SHALL replace unicode emoji placeholders with vector icons (`@phosphor-icons/react` or bespoke SVGs).
- REQ-TRN-003 (State-Driven): WHILE integrating motion components, spring physics configs SHALL replace linear transitions without altering visual layout.
- REQ-TRN-004 (Unwanted Behavior): IF an external component introduces uncontained CSS animations, THEN the agent SHALL constrain them to GPU hardware layers (`translateZ(0)`).
