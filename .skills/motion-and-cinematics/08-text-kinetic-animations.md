# Skill 08: Kinetic Typography & Tabular Numeric Tickers

## 1. System Invariants

1. Semantic Screen Reader Accessibility:
   - Split-text character and word splitting MUST preserve native accessibility.
   - Always place the intact text in a visually hidden container or declare `aria-label="Full Sentence"` on the parent element, marking split character spans with `aria-hidden="true"`.
2. Zero Layout Shift during Character Ingestion:
   - Wrap split glyph spans in `display: inline-block; overflow: hidden; vertical-align: top;`.
   - Never cause multi-line text reflow during kinetic reveals.
3. Velocity-Dependent Text Dynamics:
   - Modulate typography skew and letter spacing based on scroll velocity (e.g., `-15deg` skew at maximum scroll impulse, spring returning to `0deg`).
4. Rolling Numeric Counters:
   - Construct rolling numeric tickers using individual sliding digit columns with strict `tabular-nums` alignment.

## 2. Production Implementation

### Kinetic Headline & Tabular Numeric Ticker (`KineticTypography.tsx`)

```tsx
import React, { useEffect, useRef } from "react";
import { motion, useSpring, useTransform } from "framer-motion";

interface KineticHeadlineProps {
  text: string;
  className?: string;
}

export const KineticHeadline: React.FC<KineticHeadlineProps> = ({
  text,
  className = "",
}) => {
  const words = text.split(" ");

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.04,
        delayChildren: 0.1,
      },
    },
  };

  const charVariants = {
    hidden: { y: "115%", rotateZ: 8, opacity: 0 },
    visible: {
      y: "0%",
      rotateZ: 0,
      opacity: 1,
      transition: {
        type: "spring",
        stiffness: 300,
        damping: 24,
      },
    },
  };

  return (
    <h1
      className={`font-['Clash_Display'] font-bold leading-none tracking-tight ${className}`}
      aria-label={text}
    >
      <motion.span
        className="inline-block"
        variants={containerVariants}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.4 }}
      >
        {words.map((word, wordIndex) => (
          <span key={wordIndex} className="inline-block whitespace-nowrap mr-[0.25em]">
            {Array.from(word).map((char, charIndex) => (
              <span
                key={charIndex}
                className="inline-block overflow-hidden align-top"
                aria-hidden="true"
              >
                <motion.span
                  className="inline-block will-change-transform"
                  variants={charVariants}
                >
                  {char}
                </motion.span>
              </span>
            ))}
          </span>
        ))}
      </motion.span>
    </h1>
  );
};

interface RollingNumberTickerProps {
  value: number;
  duration?: number;
  prefix?: string;
  suffix?: string;
}

export const RollingNumberTicker: React.FC<RollingNumberTickerProps> = ({
  value,
  prefix = "",
  suffix = "",
}) => {
  const springValue = useSpring(0, {
    stiffness: 120,
    damping: 18,
  });

  const displayRef = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    springValue.set(value);
  }, [value, springValue]);

  useEffect(() => {
    const unsubscribe = springValue.on("change", (latest) => {
      if (displayRef.current) {
        displayRef.current.textContent = `${prefix}${latest.toLocaleString("en-US", {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        })}${suffix}`;
      }
    });
    return () => unsubscribe();
  }, [springValue, prefix, suffix]);

  return (
    <span
      ref={displayRef}
      className="font-mono text-2xl font-bold tracking-tight text-[oklch(0.96_0.01_250)] tabular-nums"
    >
      {prefix}0.00{suffix}
    </span>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Splitting words into raw spans without an `aria-label` or `aria-hidden="true"`, causing screen readers to spell words letter-by-letter.
- Prohibited: Animating text opacity linearly from `0` to `1` without physical translation or rotational momentum.
- Prohibited: Shifting typography vertical baseline or triggering card height resizing while numbers increment.
- Prohibited: Using arbitrary non-monospace fonts for real-time statistical tickers.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-TXT-001 (Ubiquitous): All kinetic text split animations SHALL declare `aria-label` containing the un-split text on the parent heading.
- REQ-TXT-002 (Ubiquitous): Numeric tickers SHALL update numerical data strictly with fixed decimal places and `tabular-nums` enabled.
- REQ-TXT-003 (State-Driven): WHILE the viewport scrolls into the headline visibility threshold, letters SHALL stagger into view with spring physics within 600ms total duration.
- REQ-TXT-004 (Unwanted Behavior): IF the character splitting routine encounters complex ligature characters or punctuation, THEN it SHALL wrap them cleanly without visual detachment.
