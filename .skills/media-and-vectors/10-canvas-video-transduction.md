# Skill 10: High-Performance Canvas Video Transduction & Frame Scrubbing

## 1. System Invariants

1. Decoder Stutter Prevention:
   - NEVER bind HTML5 `<video>.currentTime` directly to synchronous `window.onscroll` events. Native video decoders cannot seek keyframes at 60 FPS without dropping frames and choking the audio/video synchronization pipeline.
   - Employ an Image Sequence Canvas Buffer: Preload frames into a compressed WebP/AVIF array, drawing to an HTML5 2D Canvas via `requestAnimationFrame` during scroll scrubs.
2. Canvas Rendering Efficiency:
   - Use `ctx.drawImage()` with pre-calculated integer dimensions to prevent sub-pixel antialiasing overhead.
   - Configure context with `{ alpha: true, desynchronized: true }` where supported to bypass compositor stalls.
3. Transparent Alpha Masking:
   - For transparent video assets, use WebM VP9 with alpha channel, or render a side-by-side (RGB + Alpha Matte) frame on canvas and compose via `globalCompositeOperation = "destination-in"`.

## 2. Production Implementation

### High-FPS Scroll Frame Scrubber (`CanvasVideoScrubber.tsx`)

```tsx
import React, { useEffect, useRef, useState } from "react";

interface CanvasVideoScrubberProps {
  totalFrames: number;
  frameUrlTemplate: (index: number) => string;
  width?: number;
  height?: number;
  className?: string;
}

export const CanvasVideoScrubber: React.FC<CanvasVideoScrubberProps> = ({
  totalFrames,
  frameUrlTemplate,
  width = 1920,
  height = 1080,
  className = "",
}) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const imagesRef = useRef<HTMLImageElement[]>([]);
  const [loadProgress, setLoadProgress] = useState(0);
  const [isReady, setIsReady] = useState(false);

  // Preload frame sequences into memory buffer
  useEffect(() => {
    let loadedCount = 0;
    const images: HTMLImageElement[] = [];

    for (let i = 1; i <= totalFrames; i++) {
      const img = new Image();
      img.src = frameUrlTemplate(i);
      img.onload = () => {
        loadedCount++;
        setLoadProgress(Math.floor((loadedCount / totalFrames) * 100));
        if (loadedCount === totalFrames) {
          setIsReady(true);
        }
      };
      images.push(img);
    }
    imagesRef.current = images;

    return () => {
      images.forEach((img) => (img.onload = null));
    };
  }, [totalFrames, frameUrlTemplate]);

  // Synchronized scroll scrub loop
  useEffect(() => {
    if (!isReady || !canvasRef.current || !containerRef.current) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext("2d", { alpha: true });
    if (!ctx) return;

    let rafId: number;
    let targetFrame = 0;
    let currentFrame = 0;

    const handleScroll = () => {
      const container = containerRef.current;
      if (!container) return;
      const rect = container.getBoundingClientRect();
      const windowHeight = window.innerHeight;
      
      // Calculate normalized scroll progression (0.0 to 1.0)
      const totalScrollDistance = rect.height - windowHeight;
      const currentScroll = Math.max(0, -rect.top);
      const progress = Math.min(Math.max(currentScroll / totalScrollDistance, 0), 1);

      targetFrame = Math.floor(progress * (totalFrames - 1));
    };

    const renderLoop = () => {
      // Lerp frame index for physical inertia
      currentFrame += (targetFrame - currentFrame) * 0.15;
      const frameIndex = Math.min(Math.round(currentFrame), totalFrames - 1);

      const frameImg = imagesRef.current[frameIndex];
      if (frameImg && frameImg.complete) {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(frameImg, 0, 0, canvas.width, canvas.height);
      }

      rafId = requestAnimationFrame(renderLoop);
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    rafId = requestAnimationFrame(renderLoop);

    return () => {
      window.removeEventListener("scroll", handleScroll);
      cancelAnimationFrame(rafId);
    };
  }, [isReady, totalFrames]);

  return (
    <div ref={containerRef} className={`relative h-[300vh] w-full ${className}`}>
      <div className="sticky top-0 flex h-screen w-full items-center justify-center overflow-hidden bg-[oklch(0.12_0.015_250)]">
        {!isReady && (
          <div className="absolute z-20 flex flex-col items-center gap-2">
            <span className="font-mono text-xs uppercase tracking-widest text-[oklch(0.85_0.18_85)]">
              BUFFERING_TRANSDUCTION_FRAMES
            </span>
            <div className="h-1 w-48 overflow-hidden rounded bg-[oklch(1_0_0_/_0.1)]">
              <div
                className="h-full bg-[oklch(0.85_0.18_85)] transition-all duration-150"
                style={{ width: `${loadProgress}%` }}
              />
            </div>
            <span className="font-mono text-[10px] tabular-nums text-[oklch(0.55_0.02_250)]">
              {loadProgress}% LOADED
            </span>
          </div>
        )}
        <canvas
          ref={canvasRef}
          width={width}
          height={height}
          className="h-full w-full object-contain pointer-events-none"
        />
      </div>
    </div>
  );
};
```

## 3. Prohibited Anti-Patterns

- Prohibited: Hooking `<video onTimeUpdate>` or `.currentTime = scrollPos` directly into scroll handlers, causing catastrophic browser decoder dropouts.
- Prohibited: Loading uncompressed full-res PNG sequences that consume multiple gigabytes of browser RAM.
- Prohibited: Drawing un-synchronized canvas frames without `requestAnimationFrame`, causing micro-tearing and frame skip.
- Prohibited: Failing to clean up image loader handlers or animation loops upon unmount.

## 4. Acceptance Criteria (EARS Syntax)

- REQ-VID-001 (Ubiquitous): The scrubbing engine SHALL buffer frames into an image memory sequence before enabling user interaction.
- REQ-VID-002 (Ubiquitous): All canvas repaint operations SHALL execute strictly within `requestAnimationFrame` with linear interpolation damping between target and rendered frames.
- REQ-VID-003 (State-Driven): WHILE scrubbing bidirectionally, the frame transition cadence SHALL remain locked at 60 FPS without decoding latency.
- REQ-VID-004 (Unwanted Behavior): IF network latency delays frame sequence ingestion, THEN the UI SHALL display a precision tabular progress indicator rather than a blank or frozen canvas.
