# Skill 17: Cybernetic Text Scramble & Monospace Entropy Decoding

## 1. System Invariants

1. Progressive Entropy Resolution:
   - Text scramblers must resolve characters progressively (e.g., left-to-right or center-outward) rather than randomly flickering across the entire string at once.
   - Character replacement glyph set: Monospace technical characters (`!<>-_\\/[]{}—=+*^?#________`). Never include unicode emojis or variable-width characters.
2. Monospace Coordinate Anchorage:
   - The scrambled element MUST render inside a monospace container (`font-family: var(--font-telemetry)`) with fixed character widths to completely eliminate horizontal word jitter during permutation.
3. Screen Reader Integrity:
   - The container must maintain `aria-label="Target Text"` with the resolved text, while marking the dynamically cycling character spans with `aria-hidden="true"`.

## 2. Production Implementation

### Cybernetic Scramble Hook & Component (`TextScramble.tsx`)

```tsx
import React, { useEffect, useState, useCallback, useRef } from "react";

const GLYPHS = "01ABCDEFXYZ_#@!<>{}[]/\\+=*~";

interface TextScrambleProps {
  text: string;
  trigger?: boolean;
  speed?: number;
  className?: string;
  onComplete?: () => void;
}

export const TextScramble: React.FC<TextScrambleProps> = ({
  text,
  trigger = true,
  speed = 30,
  className = "",
  onComplete,
}) => {
  const [displayText, setDisplayText] = useState(text);
  const frameRef = useRef<number | null>(null);

  const scramble = useCallback(() => {
    let iteration = 0;
    const maxIterations = text.length * 3;

    if (frameRef.current) cancelAnimationFrame(frameRef.current);

    const step = () => {
      setDisplayText(() =>
        text
          .split("")
          .map((char, index) => {
            if (char === " ") return " ";
            if (index < iteration / 3) {
              return text[index];
            }
            return GLYPHS[Math.floor(Math.random() * GLYPHS.length)];
          })
          .join("")
      );

      if (iteration < maxIterations) {
        iteration++;
        frameRef.current = requestAnimationFrame(() => setTimeout(step, speed));
      } else {
        setDisplayText(text);
        if (onComplete) onComplete();
      }
    };

    step();
  }, [text, speed, onComplete]);

  useEffect(() => {
    if (trigger) {
      scramble();
    }
    return () => {
      if (frameRef.current) cancelAnimationFrame(frameRef.current);
    };
  }, [trigger, scramble]);

  return (
    <span
      className={`font-mono tabular-nums tracking-wider ${className}`}
      aria-label={text}
      onMouseEnter={scramble}
    >
      <span aria-hidden="true">{displayText}</span>
    </span>
  );
};

export const ScrambleTelemetryCard: React.FC = () => {
  const [keyIndex, setKeyIndex] = useState(0);
  const KEYS = [
    "CIPHER_ROTATION_256",
    "ENTROPY_BUFFER_OK",
    "SYSTEM_ZERO_SLOP",
  ];

  return (
    <div className="flex flex-col gap-2 rounded-2xl border border-[oklch(1_0_0_/_0.08)] bg-[oklch(0.12_0.015_250)] p-6">
      <div className="flex items-center justify-between">
        <span className="font-mono text-[10px] uppercase text-[oklch(0.55_0.02_250)]">
          DECRYPTION_STREAM
        </span>
        <button
          onClick={() => setKeyIndex((prev) => (prev + 1) % KEYS.length)}
          className="rounded border border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.18_0.022_250)] px-2.5 py-1 font-mono text-[10px] text-[oklch(0.85_0.18_85)] hover:bg-[oklch(0.22_0.028_250)]"
        >
          CYCLE_STREAM
        </button>
      </div>

      <div className="my-2">
        <TextScramble
          key={KEYS[keyIndex]}
          text={KEYS[keyIndex]}
          className="text-lg font-bold text-[oklch(0.96_0.01_250)]"
        />
      </div>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Scrambling text rendered in proportional sans-serif fonts, causing jarring horizontal text bouncing.
- Prohibited: Obscuring accessibility by omitting `aria-label`, forcing assistive readers to parse randomized character bursts.
- Prohibited: Incomplete cancellation of animation timeouts on component unmount, causing React state update memory leaks.
- Prohibited: Arbitrary character sets containing wide glyphs or complex emojis.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-SCR-001 (Ubiquitous): The scramble mechanism SHALL only draw replacement characters from a fixed-width monospace glyph set.
- REQ-SCR-002 (Ubiquitous): The parent DOM node SHALL declare `aria-label` with the full static target string for screen reader accessibility.
- REQ-SCR-003 (State-Driven): WHILE decoding executes, character resolution SHALL progress sequentially from index 0 to length - 1.
- REQ-SCR-004 (Unwanted Behavior): IF the trigger changes or component unmounts mid-animation, THEN all frame timers SHALL be cancelled immediately.
