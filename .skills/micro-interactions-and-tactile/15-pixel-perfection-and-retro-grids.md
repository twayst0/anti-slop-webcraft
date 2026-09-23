# Skill 15: High-FPS Canvas Pixel Cards & Retro Horizon Perspective Grids

## 1. System Invariants

1. 2D Canvas Pixel Matrix Architecture:
   - Interactive pixel cards must render discrete square pixel matrices on a dedicated `<canvas>` instead of hundreds of DOM `<div>` elements.
   - Standardize pixel dimensions between `8px` and `16px` with a `1px` structural gap.
2. Pixel Decay Physics:
   - Illuminated pixels must fade out along an exponential decay curve (`alpha = alpha * 0.92`), creating a smooth phosphorescent phosphor trail behind cursor movements.
3. Retro Horizon Mathematical Projection:
   - Perspective grids calculate perspective lines using 3D-to-2D vanishing point projection: `y_screen = horizon + (scale / z)`.
   - Grid motion MUST translate purely in z-space to simulate infinite forward travel.

## 2. Production Implementation

### High-Performance Canvas Pixel Card (`CanvasPixelCard.tsx`)

```tsx
import React, { useEffect, useRef } from "react";

interface CanvasPixelCardProps {
  children?: React.ReactNode;
  pixelSize?: number;
  gap?: number;
  className?: string;
}

export const CanvasPixelCard: React.FC<CanvasPixelCardProps> = ({
  children,
  pixelSize = 12,
  gap = 2,
  className = "",
}) => {
  const containerRef = useRef<HTMLDivElement>(null!);
  const canvasRef = useRef<HTMLCanvasElement>(null!);
  const gridState = useRef<{ [key: string]: number }>({});
  const pointerPos = useRef<{ x: number; y: number }>({ x: -1000, y: -1000 });

  useEffect(() => {
    const container = containerRef.current;
    const canvas = canvasRef.current;
    if (!container || !canvas) return;

    const ctx = canvas.getContext("2d", { alpha: true });
    if (!ctx) return;

    let rafId: number;

    const resize = () => {
      canvas.width = container.clientWidth;
      canvas.height = container.clientHeight;
    };
    resize();
    window.addEventListener("resize", resize);

    const handlePointerMove = (e: MouseEvent) => {
      const rect = container.getBoundingClientRect();
      pointerPos.current = {
        x: e.clientX - rect.left,
        y: e.clientY - rect.top,
      };
    };

    const handlePointerLeave = () => {
      pointerPos.current = { x: -1000, y: -1000 };
    };

    container.addEventListener("mousemove", handlePointerMove);
    container.addEventListener("mouseleave", handlePointerLeave);

    const step = pixelSize + gap;

    const render = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const cols = Math.ceil(canvas.width / step);
      const rows = Math.ceil(canvas.height / step);

      // Light up pixels in pointer radius
      if (pointerPos.current.x >= 0) {
        const centerCol = Math.floor(pointerPos.current.x / step);
        const centerRow = Math.floor(pointerPos.current.y / step);
        const radius = 3;

        for (let r = -radius; r <= radius; r++) {
          for (let c = -radius; c <= radius; c++) {
            const col = centerCol + c;
            const row = centerRow + r;
            if (col >= 0 && col < cols && row >= 0 && row < rows) {
              const dist = Math.sqrt(r * r + c * c);
              if (dist <= radius) {
                const key = `${col}_${row}`;
                const intensity = (1 - dist / radius);
                gridState.current[key] = Math.max(gridState.current[key] || 0, intensity);
              }
            }
          }
        }
      }

      // Draw active pixels & decay alpha
      Object.keys(gridState.current).forEach((key) => {
        const val = gridState.current[key];
        if (val > 0.01) {
          const [col, row] = key.split("_").map(Number);
          ctx.fillStyle = `oklch(0.85 0.18 85 / ${(val * 0.4).toFixed(3)})`;
          ctx.fillRect(col * step, row * step, pixelSize, pixelSize);
          gridState.current[key] = val * 0.92;
        } else {
          delete gridState.current[key];
        }
      });

      rafId = requestAnimationFrame(render);
    };
    render();

    return () => {
      cancelAnimationFrame(rafId);
      window.removeEventListener("resize", resize);
      container.removeEventListener("mousemove", handlePointerMove);
      container.removeEventListener("mouseleave", handlePointerLeave);
    };
  }, [pixelSize, gap]);

  return (
    <div
      ref={containerRef}
      className={`relative overflow-hidden rounded-2xl border border-[oklch(1_0_0_/_0.1)] bg-[oklch(0.14_0.018_250)] p-8 ${className}`}
    >
      <canvas ref={canvasRef} className="pointer-events-none absolute inset-0 h-full w-full" />
      <div className="relative z-10">{children}</div>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Generating thousands of HTML `<div>` nodes to represent interactive grid pixels.
- Prohibited: Allocating objects or string keys continuously during 60 FPS canvas redraw loops.
- Prohibited: Neon saturated rainbow colors (`#ff00ff`, `#00ffff`) without OKLCH perceptual calibration.
- Prohibited: Leaving canvas resize listeners without element disconnection handling.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-PIX-001 (Ubiquitous): Pixel interaction cards SHALL execute via a single HTML5 2D canvas context with zero DOM element duplication.
- REQ-PIX-002 (Ubiquitous): Active pixels SHALL decay along an exponential decay function reaching zero opacity within 400ms of pointer departure.
- REQ-PIX-003 (State-Driven): WHILE pointer remains stationary over the card, the animation loop SHALL maintain sub-2ms frame execution time.
- REQ-PIX-004 (Unwanted Behavior): IF the viewport resizes, THEN the canvas internal coordinate buffer SHALL scale synchronously without clearing card layout content.
