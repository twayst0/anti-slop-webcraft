# Skill 21: iOS-Native Fluid Bottom Sheets & Velocity Gesture Drawers

## 1. System Invariants

1. Velocity-Based Kinematic Dismissal:
   - Bottom drawers and modal sheets MUST respond to pointer flick velocity (`drag="y"`, `dragVelocity.y > 500`) to initiate dismissal, rather than relying solely on arbitrary pixel displacement thresholds.
   - Employ rubber-band damping (`dragElastic={{ top: 0.05, bottom: 0.4 }}`) to emulate physical boundary resistance when over-dragging beyond limits.
2. Multi-Point Snap Positions:
   - Standardize drawer snap points on viewport height fractions: collapsed preview (`0.25`), intermediate telemetry (`0.60`), and expanded viewport (`0.95`).
   - Settle states must compute via second-order spring dynamics (`stiffness: 300, damping: 30`).
3. Dynamic Transmission Backdrop:
   - Backdrop blur (`blur(24px)`) and ground opacity must interpolate continuously with drag displacement, reaching 100% at expanded snap and 0% at dismissal threshold.

## 2. Production Implementation

### Fluid Gesture Bottom Sheet (`FluidBottomSheet.tsx`)

```tsx
import React, { useRef } from "react";
import { motion, useMotionValue, useTransform, AnimatePresence, PanInfo } from "framer-motion";
import { X, ArrowsOutSimple, ShieldCheck } from "@phosphor-icons/react";

interface FluidBottomSheetProps {
  isOpen: boolean;
  onClose: () => void;
  children: React.ReactNode;
  title?: string;
}

export const FluidBottomSheet: React.FC<FluidBottomSheetProps> = ({
  isOpen,
  onClose,
  children,
  title = "PANEL_TELEMETRY",
}) => {
  const dragY = useMotionValue(0);

  // Dynamic backdrop opacity coupled to drag displacement
  const backdropOpacity = useTransform(dragY, [0, 400], [0.8, 0]);

  const handleDragEnd = (_: MouseEvent | TouchEvent | PointerEvent, info: PanInfo) => {
    // Dismiss if pulled down with velocity or dragged past threshold
    if (info.velocity.y > 600 || info.offset.y > 180) {
      onClose();
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-end justify-center">
          {/* Dynamic Backdrop Transmission */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            style={{ opacity: backdropOpacity }}
            onClick={onClose}
            className="fixed inset-0 bg-[oklch(0.08_0.015_250_/_0.7)] backdrop-blur-xl"
          />

          {/* Draggable Fluid Surface Slab */}
          <motion.div
            initial={{ y: "100%" }}
            animate={{ y: "0%" }}
            exit={{ y: "100%" }}
            transition={{ type: "spring", stiffness: 320, damping: 32 }}
            drag="y"
            dragConstraints={{ top: 0, bottom: 0 }}
            dragElastic={{ top: 0.05, bottom: 0.6 }}
            style={{ y: dragY }}
            onDragEnd={handleDragEnd}
            className="relative z-10 flex max-h-[90vh] w-full max-w-2xl flex-col rounded-t-3xl border-t border-x border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.14_0.018_250)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.25),0_-20px_40px_-10px_oklch(0_0_0_/_0.6)] backdrop-blur-2xl"
          >
            {/* Grab Handle Pill */}
            <div className="flex w-full justify-center pt-3 pb-2 cursor-grab active:cursor-grabbing">
              <div className="h-1 w-10 rounded-full bg-[oklch(1_0_0_/_0.25)] transition-colors hover:bg-[oklch(0.85_0.18_85)]" />
            </div>

            {/* Header Telemetry Rail */}
            <div className="flex items-center justify-between border-b border-[oklch(1_0_0_/_0.06)] px-6 py-3">
              <div className="flex items-center gap-2">
                <ShieldCheck size={16} weight="regular" className="text-[oklch(0.85_0.18_85)]" />
                <span className="font-mono text-xs uppercase tracking-wider text-[oklch(0.65_0.02_250)]">
                  {title}
                </span>
              </div>
              <button
                onClick={onClose}
                className="flex h-7 w-7 items-center justify-center rounded-lg border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.18_0.022_250)] text-[oklch(0.65_0.02_250)] transition-colors hover:text-[oklch(0.96_0.01_250)]"
              >
                <X size={14} weight="bold" />
              </button>
            </div>

            {/* Scrollable Content Container */}
            <div className="overflow-y-auto p-6">{children}</div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Implementing bottom sheets with static CSS `bottom: -100%` transitions that cannot be dragged or dismissed by gestures.
- Prohibited: Abrupt modal close on slight pointer touch without velocity consideration.
- Prohibited: Unbounded dragging that exposes layout voids or glitches underlying content.
- Prohibited: Locking document body scroll without scrollbar compensation, causing horizontal layout jumps.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-SHT-001 (Ubiquitous): The bottom sheet component SHALL track pointer gesture velocity and execute physics dismissal when downward flick speed exceeds 500px/s.
- REQ-SHT-002 (Ubiquitous): The sheet chassis SHALL apply physical elastic damping when dragged above its maximum constraint boundary.
- REQ-SHT-003 (State-Driven): WHILE dragged along the vertical axis, the backdrop blur opacity SHALL interpolate synchronously with drawer displacement.
- REQ-SHT-004 (Unwanted Behavior): IF the user releases drag before reaching velocity or displacement thresholds, THEN the sheet SHALL spring back to rest position within 220ms.
