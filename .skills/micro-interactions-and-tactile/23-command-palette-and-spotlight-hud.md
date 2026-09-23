# Skill 23: Keyboard-Driven Command Palettes & Telemetry Spotlight HUDs

## 1. System Invariants

1. Global Keyboard Orchestration:
   - Command palette MUST listen globally to `Meta+K` (macOS) and `Control+K` (Windows/Linux) hotkeys to toggle modal visibility.
   - Escape key (`Escape`) must unconditionally close the palette and restore focus to the previous active element.
   - Arrow keys (`ArrowUp`, `ArrowDown`) navigate item selection with index wrapping; `Enter` executes the active command.
2. Fuzzy Substring Scoring:
   - Filter query strings using case-insensitive fuzzy matching that scores contiguous character hits and word-boundary matches higher than arbitrary scattered hits.
3. Optical Elevation & Cockpit Aesthetics:
   - The palette modal chassis MUST feature frosted physical glass (`oklch(0.14 0.018 250 / 0.85)`), 1px specular highlight, and an optical spotlight field behind the search input.

## 2. Production Implementation

### Complete Keyboard Spotlight Palette (`CommandPalette.tsx`)

```tsx
import React, { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { MagnifyingGlass, Terminal, Cpu, Database, Gear, ArrowRight } from "@phosphor-icons/react";

interface CommandItem {
  id: string;
  title: string;
  category: "ACTIONS" | "NAVIGATION" | "SYSTEM";
  shortcut?: string;
  icon: React.ReactNode;
  action: () => void;
}

const COMMANDS: CommandItem[] = [
  { id: "1", title: "Initialize Fullscreen Noise Shader", category: "ACTIONS", shortcut: "S", icon: <Cpu size={16} />, action: () => {} },
  { id: "2", title: "Open Telemetry Cockpit Dashboard", category: "NAVIGATION", shortcut: "D", icon: <Terminal size={16} />, action: () => {} },
  { id: "3", title: "Flush GPGPU Particle Cache", category: "SYSTEM", shortcut: "F", icon: <Database size={16} />, action: () => {} },
  { id: "4", title: "Verify Anti-Slop Specification", category: "ACTIONS", shortcut: "V", icon: <Gear size={16} />, action: () => {} },
];

export const CommandPalette: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [selectedIndex, setSelectedIndex] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);

  // Global Hotkey Listener
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        setIsOpen((prev) => !prev);
      }
      if (e.key === "Escape" && isOpen) {
        setIsOpen(false);
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen]);

  // Focus Input on Open
  useEffect(() => {
    if (isOpen) {
      setTimeout(() => inputRef.current?.focus(), 50);
      setSelectedIndex(0);
    } else {
      setQuery("");
    }
  }, [isOpen]);

  const filteredCommands = COMMANDS.filter((cmd) =>
    cmd.title.toLowerCase().includes(query.toLowerCase())
  );

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setSelectedIndex((prev) => (prev + 1) % Math.max(1, filteredCommands.length));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setSelectedIndex((prev) => (prev - 1 + filteredCommands.length) % Math.max(1, filteredCommands.length));
    } else if (e.key === "Enter" && filteredCommands[selectedIndex]) {
      e.preventDefault();
      filteredCommands[selectedIndex].action();
      setIsOpen(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-start justify-center pt-24 px-4">
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setIsOpen(false)}
            className="fixed inset-0 bg-[oklch(0.08_0.015_250_/_0.75)] backdrop-blur-xl"
          />

          {/* Palette Dialog */}
          <motion.div
            initial={{ opacity: 0, scale: 0.96, y: -10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.96, y: -10 }}
            transition={{ type: "spring", stiffness: 400, damping: 30 }}
            className="relative z-10 w-full max-w-xl overflow-hidden rounded-2xl border border-[oklch(1_0_0_/_0.15)] bg-[oklch(0.14_0.018_250_/_0.9)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.25),0_24px_48px_-12px_oklch(0_0_0_/_0.7)] backdrop-blur-2xl"
          >
            {/* Search Input Bar */}
            <div className="flex items-center gap-3 border-b border-[oklch(1_0_0_/_0.08)] px-4 py-3.5">
              <MagnifyingGlass size={18} weight="bold" className="text-[oklch(0.85_0.18_85)]" />
              <input
                ref={inputRef}
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  setSelectedIndex(0);
                }}
                onKeyDown={handleKeyDown}
                placeholder="Search commands, skills, or telemetry specs..."
                className="w-full bg-transparent font-mono text-sm text-[oklch(0.96_0.01_250)] placeholder-[oklch(0.45_0.02_250)] outline-none"
              />
              <span className="rounded border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.18_0.022_250)] px-2 py-0.5 font-mono text-[10px] text-[oklch(0.55_0.02_250)]">
                ESC
              </span>
            </div>

            {/* Filtered Action List */}
            <div className="max-h-72 overflow-y-auto p-2">
              {filteredCommands.length > 0 ? (
                filteredCommands.map((cmd, index) => {
                  const isSelected = index === selectedIndex;
                  return (
                    <div
                      key={cmd.id}
                      onClick={() => {
                        cmd.action();
                        setIsOpen(false);
                      }}
                      onMouseEnter={() => setSelectedIndex(index)}
                      className={`flex cursor-pointer items-center justify-between rounded-xl px-3 py-2.5 transition-colors ${
                        isSelected
                          ? "bg-[oklch(0.20_0.025_250)] text-[oklch(0.96_0.01_250)] shadow-[inset_0_1px_0_0_oklch(1_0_0_/_0.15)]"
                          : "text-[oklch(0.65_0.02_250)] hover:text-[oklch(0.85_0.01_250)]"
                      }`}
                    >
                      <div className="flex items-center gap-3">
                        <span className={isSelected ? "text-[oklch(0.85_0.18_85)]" : "text-[oklch(0.45_0.02_250)]"}>
                          {cmd.icon}
                        </span>
                        <span className="font-mono text-xs tracking-wide">{cmd.title}</span>
                      </div>

                      <div className="flex items-center gap-2">
                        {cmd.shortcut && (
                          <span className="rounded border border-[oklch(1_0_0_/_0.1)] px-1.5 py-0.5 font-mono text-[9px] text-[oklch(0.55_0.02_250)]">
                            {cmd.shortcut}
                          </span>
                        )}
                        {isSelected && <ArrowRight size={12} weight="bold" className="text-[oklch(0.85_0.18_85)]" />}
                      </div>
                    </div>
                  );
                })
              ) : (
                <div className="p-6 text-center font-mono text-xs text-[oklch(0.45_0.02_250)]">
                  NO_TELEMETRY_RECORDS_MATCHED
                </div>
              )}
            </div>

            {/* Footer Telemetry Legend */}
            <div className="flex items-center justify-between border-t border-[oklch(1_0_0_/_0.06)] bg-[oklch(0.12_0.015_250)] px-4 py-2 font-mono text-[10px] text-[oklch(0.45_0.02_250)]">
              <span>NAVIGATE: ARROW_KEYS</span>
              <span>SELECT: ENTER</span>
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Missing keyboard arrow selection listeners, requiring users to reach for the mouse.
- Prohibited: Failing to auto-focus search input when palette opens.
- Prohibited: Heavy un-debounced search routines on massive data structures that lock up the input thread.
- Prohibited: Plain white or generic dark modals lacking optical transmission and directional hairlines.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-CMD-001 (Ubiquitous): The command palette SHALL toggle visibility on global `Cmd+K` / `Ctrl+K` keypresses across the entire web application.
- REQ-CMD-002 (Ubiquitous): Pressing `Escape` SHALL close the dialog and restore keyboard focus to the preceding trigger element.
- REQ-CMD-003 (State-Driven): WHILE query text is entered, the results list SHALL filter matching records within 4ms without frame drop.
- REQ-CMD-004 (Unwanted Behavior): IF arrow navigation reaches list boundaries, THEN index selection SHALL wrap cleanly to opposite boundary.
