# Skill 12: macOS-Style Interactive Dock & Liquid Spring Tabs

## 1. System Invariants

1. Mathematical Proximity Magnification:
   - Calculate icon scale via continuous cosine or Gaussian curve based on pointer distance from element center: `f(d) = base + (max - base) * cos(min(|d| / radius, 1.0) * PI / 2)`.
   - Never use sudden stepped hover sizes (`hover:scale-125`). Scales must modulate smoothly across adjacent neighbors.
2. Fluid Spring Sliding Pill:
   - Active tab indicators MUST slide smoothly between tabs utilizing Framer Motion `layoutId="active-pill"` with spring physics (`stiffness: 400, damping: 32`).
3. True Frosted Slab Physicality:
   - Dock chassis must declare `backdrop-filter: blur(20px) saturate(180%)`, 1px directional hairline top border, and rounded pill contours (`rounded-full`).

## 2. Production Implementation

### Interactive Magnification Dock (`InteractiveDock.tsx`)

```tsx
import React, { useRef } from "react";
import { motion, useMotionValue, useSpring, useTransform, MotionValue } from "framer-motion";
import { Terminal, Code, Cpu, HardDrives, Gear, ShieldCheck } from "@phosphor-icons/react";

interface DockItemProps {
  mouseX: MotionValue<number>;
  icon: React.ReactNode;
  label: string;
  onClick?: () => void;
}

const DockItem: React.FC<DockItemProps> = ({ mouseX, icon, label, onClick }) => {
  const ref = useRef<HTMLDivElement>(null);

  const distance = useTransform(mouseX, (val) => {
    const bounds = ref.current?.getBoundingClientRect() ?? { x: 0, width: 0 };
    return val - bounds.x - bounds.width / 2;
  });

  // Gaussian scale distribution across neighbors
  const widthSync = useTransform(distance, [-120, 0, 120], [44, 72, 44]);
  const width = useSpring(widthSync, { mass: 0.1, stiffness: 220, damping: 14 });

  return (
    <motion.div
      ref={ref}
      style={{ width, height: width }}
      onClick={onClick}
      className="group relative flex cursor-pointer items-center justify-center rounded-full border border-[oklch(1_0_0_/_0.12)] bg-[oklch(0.20_0.025_250_/_0.7)] text-[oklch(0.92_0.01_250)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.2)] transition-colors hover:bg-[oklch(0.25_0.03_250_/_0.85)] hover:text-[oklch(0.85_0.18_85)]"
    >
      <div className="flex items-center justify-center">{icon}</div>

      {/* Optical Tooltip Tag */}
      <span className="pointer-events-none absolute -top-8 whitespace-nowrap rounded border border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.12_0.015_250_/_0.95)] px-2 py-0.5 font-mono text-[9px] uppercase tracking-wider text-[oklch(0.96_0.01_250)] opacity-0 shadow-md backdrop-blur-md transition-opacity duration-150 group-hover:opacity-100">
        {label}
      </span>
    </motion.div>
  );
};

export const InteractiveDockBar: React.FC = () => {
  const mouseX = useMotionValue(Infinity);

  const DOCK_ITEMS = [
    { id: "term", icon: <Terminal size={22} weight="regular" />, label: "TERMINAL" },
    { id: "code", icon: <Code size={22} weight="regular" />, label: "COMPILER" },
    { id: "core", icon: <Cpu size={22} weight="regular" />, label: "NEURAL_CORE" },
    { id: "disk", icon: <HardDrives size={22} weight="regular" />, label: "STORAGE" },
    { id: "sec", icon: <ShieldCheck size={22} weight="regular" />, label: "SECURITY" },
    { id: "cfg", icon: <Gear size={22} weight="regular" />, label: "CONFIG" },
  ];

  return (
    <div className="flex w-full justify-center p-6">
      <motion.div
        onMouseMove={(e) => mouseX.set(e.pageX)}
        onMouseLeave={() => mouseX.set(Infinity)}
        className="flex h-16 items-end gap-3 rounded-full border border-[oklch(1_0_0_/_0.12)] bg-[oklch(0.14_0.018_250_/_0.75)] px-4 pb-2.5 shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.25),0_20px_40px_-15px_oklch(0_0_0_/_0.6)] backdrop-blur-2xl"
      >
        {DOCK_ITEMS.map((item) => (
          <DockItem key={item.id} mouseX={mouseX} icon={item.icon} label={item.label} />
        ))}
      </motion.div>
    </div>
  );
};
```

### Liquid Spring Tab Selector (`LiquidTabs.tsx`)

```tsx
import React, { useState } from "react";
import { motion } from "framer-motion";

const TABS = [
  { id: "overview", label: "OVERVIEW" },
  { id: "telemetry", label: "TELEMETRY" },
  { id: "shaders", label: "SHADERS" },
  { id: "memory", label: "MEMORY" },
];

export const LiquidTabs: React.FC = () => {
  const [activeTab, setActiveTab] = useState(TABS[0].id);

  return (
    <div className="inline-flex rounded-xl border border-[oklch(1_0_0_/_0.08)] bg-[oklch(0.12_0.015_250)] p-1">
      {TABS.map((tab) => {
        const isActive = activeTab === tab.id;
        return (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`relative rounded-lg px-4 py-1.5 font-mono text-xs uppercase tracking-wider transition-colors duration-200 ${
              isActive ? "text-[oklch(0.96_0.01_250)]" : "text-[oklch(0.55_0.02_250)] hover:text-[oklch(0.85_0.01_250)]"
            }`}
          >
            {isActive && (
              <motion.div
                layoutId="liquid-tab-pill"
                transition={{ type: "spring", stiffness: 380, damping: 30 }}
                className="absolute inset-0 rounded-lg border border-[oklch(0.85_0.18_85_/_0.3)] bg-[oklch(0.20_0.025_250)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.2)]"
              />
            )}
            <span className="relative z-10">{tab.label}</span>
          </button>
        );
      })}
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Abrupt CSS transition `transition: transform 0.2s` for dock icons causing jagged stepped jumps.
- Prohibited: Re-rendering full React trees on pointer coordinates rather than using reactive `MotionValue` pipelines.
- Prohibited: Generic active tab styling using plain blue borders or underline transitions without spatial spring physics.
- Prohibited: Unbounded magnification that causes dock icons to overflow viewport boundaries.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-DCK-001 (Ubiquitous): The dock component SHALL compute item scales using distance functions that dynamically affect at least 2 neighboring icons on each side.
- REQ-DCK-002 (Ubiquitous): The active tab indicator SHALL transition between tabs via `layoutId` spring physics without unmounting.
- REQ-DCK-003 (State-Driven): WHILE pointer leaves the dock area, all icons SHALL spring back to default rest dimensions within 200ms.
- REQ-DCK-004 (Unwanted Behavior): IF touch interaction is detected, THEN the dock SHALL bypass continuous distance calculation and execute direct select physics.
