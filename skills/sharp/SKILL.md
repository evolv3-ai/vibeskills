---
name: sharp
description: |
  Processes images with Sharp, the high-performance Node.js library for resizing, converting, and optimizing images. Use when building image pipelines, generating thumbnails, batch processing client photos, or optimizing uploads server-side.

  Use when: resizing photos, converting to WebP/AVIF, batch optimization, thumbnail generation, watermarks. Errors: "Input file is missing", "unsupported image format", "memory allocation failed", "sharp: Installation failed".
license: Apache-2.0
metadata:
  version: 0.34.5
  last_verified: 2026-01-05
  packages:
    - "sharp@0.34.5"
  node_version: "^18.17.0 || >= 20.3.0"
---

# Sharp

High-performance Node.js image processing. 4-5x faster than ImageMagick for resizing JPEG, PNG, WebP, GIF, AVIF, and TIFF images. Uses libvips under the hood.

**Supported Runtimes**: Node.js (^18.17.0 or >= 20.3.0), Deno, Bun

## Quick Start

```bash
npm install sharp
```

```javascript
import sharp from 'sharp';

// Resize and convert
await sharp('input.jpg')
  .resize(800, 600)
  .toFormat('webp')
  .toFile('output.webp');

// From buffer
const buffer = await sharp(inputBuffer)
  .resize(400)
  .toBuffer();
```

## Constructor Options

```javascript
// With input options
const image = sharp('input.jpg', {
  animated: true,           // Extract all frames from GIF/WebP
  limitInputPixels: 268402689,  // Max input pixels (default ~268M)
  failOn: 'warning',        // When to abort: 'none', 'truncated', 'error', 'warning'
  density: 300,             // DPI for vector input (SVG, PDF)
  pages: -1,                // All pages (-1) or specific count
  page: 0,                  // Starting page
});

// From raw pixel data
const raw = sharp(buffer, {
  raw: {
    width: 800,
    height: 600,
    channels: 4  // RGBA
  }
});

// Create new image from scratch
const blank = sharp({
  create: {
    width: 800,
    height: 600,
    channels: 4,
    background: { r: 255, g: 255, b: 255, alpha: 1 }
  }
});
```

## Resize

```javascript
// Fixed dimensions (may crop based on fit)
await sharp('input.jpg')
  .resize(800, 600)
  .toFile('output.jpg');

// Fit within dimensions (maintain aspect ratio)
await sharp('input.jpg')
  .resize(800, 600, { fit: 'inside' })
  .toFile('output.jpg');

// Fill dimensions (crop to fit)
await sharp('input.jpg')
  .resize(800, 600, { fit: 'cover' })
  .toFile('output.jpg');

// Width only (auto height)
await sharp('input.jpg')
  .resize({ width: 800 })
  .toFile('output.jpg');

// Without upscaling
await sharp('input.jpg')
  .resize(2000, null, { withoutEnlargement: true })
  .toFile('output.jpg');

// Without downscaling
await sharp('input.jpg')
  .resize(200, null, { withoutReduction: true })
  .toFile('output.jpg');
```

### Fit Options

| Option | Description |
|--------|-------------|
| `cover` | Crop to cover dimensions (default) |
| `contain` | Fit within, add background if needed |
| `fill` | Stretch to fill (ignores aspect ratio) |
| `inside` | Fit within, never exceed dimensions |
| `outside` | Fit to cover, may exceed one dimension |

### Position (for cover/contain)

```javascript
await sharp('input.jpg')
  .resize(800, 600, {
    fit: 'cover',
    position: 'top'  // top, right top, right, right bottom, bottom, left bottom, left, left top, center
  })
  .toFile('output.jpg');

// Smart crop strategies
await sharp('input.jpg')
  .resize(800, 600, {
    fit: 'cover',
    position: sharp.strategy.entropy   // Focus on high-detail region
  })
  .toFile('output.jpg');

await sharp('input.jpg')
  .resize(800, 600, {
    fit: 'cover',
    position: sharp.strategy.attention  // Focus on faces/skin tones
  })
  .toFile('output.jpg');
```

### Resize Kernels

```javascript
await sharp('input.jpg')
  .resize(800, 600, {
    kernel: 'lanczos3'  // lanczos3 (default), lanczos2, nearest, cubic, mitchell, linear
  })
  .toFile('output.jpg');
```

## Format Conversion

```javascript
// To WebP
await sharp('input.jpg')
  .webp({ quality: 80 })
  .toFile('output.webp');

// To AVIF (best compression)
await sharp('input.jpg')
  .avif({ quality: 60 })
  .toFile('output.avif');

// To PNG
await sharp('input.jpg')
  .png({ compressionLevel: 9 })
  .toFile('output.png');

// To JPEG
await sharp('input.png')
  .jpeg({ quality: 80, mozjpeg: true })
  .toFile('output.jpg');

// To GIF
await sharp('input.jpg')
  .gif()
  .toFile('output.gif');

// To HEIF (requires libheif)
await sharp('input.jpg')
  .heif({ quality: 80, compression: 'av1' })
  .toFile('output.heif');

// Auto format based on extension
await sharp('input.jpg')
  .toFormat('webp', { quality: 80 })
  .toFile('output.webp');
```

### Format Options

```javascript
// JPEG
.jpeg({
  quality: 80,           // 1-100
  progressive: true,     // Progressive JPEG
  mozjpeg: true,         // MozJPEG encoder (better compression)
  chromaSubsampling: '4:4:4',  // or '4:2:0' (default)
  trellisQuantisation: true,
  overshootDeringing: true,
})

// PNG
.png({
  compressionLevel: 9,   // 0-9
  palette: true,         // Quantize to palette
  quality: 80,           // For palette mode (1-100)
  colors: 256,           // Max colors for palette
  dither: 1.0,           // Floyd-Steinberg dithering
})

// WebP
.webp({
  quality: 80,           // 1-100
  lossless: false,       // Lossless compression
  nearLossless: false,   // Near-lossless mode
  effort: 4,             // 0-6, higher = slower + smaller
  loop: 0,               // Animation loops (0 = infinite)
  delay: 100,            // Frame delay in ms
})

// AVIF
.avif({
  quality: 60,           // 1-100
  effort: 4,             // 0-9, higher = slower + smaller
  lossless: false,
  chromaSubsampling: '4:4:4',
})

// GIF
.gif({
  colors: 256,           // 2-256 palette colors
  effort: 7,             // 1-10
  loop: 0,               // 0 = infinite loop
  delay: 100,            // Frame delay in ms (or array)
  dither: 1.0,           // Floyd-Steinberg dithering
})

// TIFF
.tiff({
  quality: 80,
  compression: 'lzw',    // lzw, deflate, jpeg, ccittfax4, etc.
  bitdepth: 8,           // 1, 2, 4, 8
  tile: true,            // Tiled TIFF
  tileWidth: 256,
  tileHeight: 256,
})
```

## Animated Images (GIF/WebP)

```javascript
// Read animated GIF/WebP
const image = sharp('animated.gif', { animated: true });

// Get frame count
const metadata = await image.metadata();
console.log(`Frames: ${metadata.pages}, Delay: ${metadata.delay}`);

// Resize animated image (preserves animation)
await sharp('animated.gif', { animated: true })
  .resize(400)
  .gif()
  .toFile('resized.gif');

// Convert animated GIF to WebP
await sharp('animated.gif', { animated: true })
  .webp({ loop: 0 })  // 0 = infinite loop
  .toFile('animated.webp');

// Extract single frame
await sharp('animated.gif', { pages: 1, page: 5 })  // Frame 5
  .toFile('frame5.png');
```

## Metadata

```javascript
// Get image info
const metadata = await sharp('input.jpg').metadata();
console.log(metadata);
// { width, height, format, space, channels, depth, density,
//   hasAlpha, pages, loop, delay, isProgressive, ... }

// Get stats (pixel analysis)
const stats = await sharp('input.jpg').stats();
console.log(stats);
// { channels: [{ min, max, sum, squaresSum, mean, stdev, ... }] }

// Keep EXIF/XMP/IPTC metadata in output
await sharp('input.jpg')
  .keepMetadata()
  .resize(800)
  .toFile('output.jpg');

// Selectively keep metadata
await sharp('input.jpg')
  .withMetadata({
    orientation: 1,      // Override orientation
    density: 300,        // Set DPI
    exif: { IFD0: { Copyright: 'My Company' } }
  })
  .toFile('output.jpg');
```

## Operations

### Crop/Extract

```javascript
// Extract region
await sharp('input.jpg')
  .extract({ left: 100, top: 100, width: 300, height: 200 })
  .toFile('output.jpg');

// Trim whitespace/borders
await sharp('input.jpg')
  .trim()  // Auto-detect border color
  .toFile('output.jpg');

await sharp('input.jpg')
  .trim({ threshold: 10 })  // Tolerance for border detection
  .toFile('output.jpg');
```

### Rotate & Flip

```javascript
// Rotate (auto from EXIF by default)
await sharp('input.jpg')
  .rotate(90)  // Degrees clockwise
  .toFile('output.jpg');

// Rotate with background
await sharp('input.jpg')
  .rotate(45, { background: { r: 255, g: 255, b: 255 } })
  .toFile('output.jpg');

// Flip
await sharp('input.jpg')
  .flip()   // Vertical
  .flop()   // Horizontal
  .toFile('output.jpg');

// Auto-orient from EXIF (default behavior)
await sharp('input.jpg')
  .rotate()  // No angle = use EXIF orientation
  .toFile('output.jpg');
```

### Color Adjustments

```javascript
await sharp('input.jpg')
  .grayscale()
  .toFile('output.jpg');

await sharp('input.jpg')
  .tint({ r: 255, g: 200, b: 200 })
  .toFile('output.jpg');

await sharp('input.jpg')
  .modulate({
    brightness: 1.2,  // 1 = no change
    saturation: 0.8,  // 0 = grayscale, 1 = no change
    hue: 180,         // Degrees rotation
    lightness: 10,    // Add/subtract lightness
  })
  .toFile('output.jpg');

await sharp('input.jpg')
  .negate()  // Invert colors
  .toFile('output.jpg');

await sharp('input.jpg')
  .negate({ alpha: false })  // Don't negate alpha
  .toFile('output.jpg');
```

### Effects

```javascript
// Blur
await sharp('input.jpg')
  .blur(5)  // Sigma value, 0.3-1000
  .toFile('output.jpg');

// Sharpen
await sharp('input.jpg')
  .sharpen()  // Default
  .toFile('output.jpg');

await sharp('input.jpg')
  .sharpen({
    sigma: 1,    // Gaussian mask size
    m1: 1,       // Flat areas
    m2: 3,       // Jagged areas
    x1: 2,       // Threshold for flat
    y2: 10,      // Max for m1
    y3: 20,      // Max for m2
  })
  .toFile('output.jpg');

// Normalize (stretch contrast)
await sharp('input.jpg')
  .normalize()
  .toFile('output.jpg');

// Median filter (noise reduction)
await sharp('input.jpg')
  .median(3)  // Window size
  .toFile('output.jpg');

// Gamma correction
await sharp('input.jpg')
  .gamma(2.2)  // Apply gamma
  .gamma(2.2, 1.8)  // Different for RGB and alpha
  .toFile('output.jpg');

// Recomb (color matrix transformation)
await sharp('input.jpg')
  .recomb([
    [0.3588, 0.7044, 0.1368],  // Sepia effect
    [0.2990, 0.5870, 0.1140],
    [0.2392, 0.4696, 0.0912],
  ])
  .toFile('output.jpg');
```

### Composite (Overlays/Watermarks)

```javascript
// Add watermark
await sharp('input.jpg')
  .composite([
    {
      input: 'watermark.png',
      gravity: 'southeast',
      blend: 'over',
    }
  ])
  .toFile('output.jpg');

// Multiple overlays
await sharp('base.jpg')
  .composite([
    { input: 'layer1.png', top: 0, left: 0 },
    { input: 'layer2.png', top: 100, left: 100, blend: 'multiply' },
    {
      input: Buffer.from('<svg>...</svg>'),
      top: 50,
      left: 50,
    }
  ])
  .toFile('output.jpg');

// Text overlay via SVG
const textSvg = `
  <svg width="400" height="50">
    <text x="0" y="35" font-size="30" fill="white">© My Company</text>
  </svg>
`;

await sharp('input.jpg')
  .composite([
    {
      input: Buffer.from(textSvg),
      gravity: 'south',
    }
  ])
  .toFile('output.jpg');

// Blend modes
// over, clear, source, in, out, atop, dest, dest-over, dest-in,
// dest-out, dest-atop, xor, add, saturate, multiply, screen,
// overlay, darken, lighten, colour-dodge, color-dodge,
// colour-burn, color-burn, hard-light, soft-light, difference,
// exclusion
```

### Add Background/Extend

```javascript
// Add padding with background color
await sharp('input.png')
  .extend({
    top: 20,
    bottom: 20,
    left: 20,
    right: 20,
    background: { r: 255, g: 255, b: 255, alpha: 1 }
  })
  .toFile('output.png');

// Extend with strategy
await sharp('input.png')
  .extend({
    top: 50,
    background: { r: 0, g: 0, b: 0 },
    extendWith: 'mirror'  // copy, repeat, mirror, background
  })
  .toFile('output.png');

// Flatten transparency to solid background
await sharp('input.png')
  .flatten({ background: '#ffffff' })
  .toFile('output.jpg');
```

## Pipeline Chaining

```javascript
// All operations chain together
await sharp('input.jpg')
  .resize(800, 600, { fit: 'cover' })
  .rotate(90)
  .sharpen()
  .modulate({ brightness: 1.1 })
  .webp({ quality: 80 })
  .toFile('output.webp');
```

## Clone for Parallel Processing

```javascript
// Clone to create multiple outputs from single input
const pipeline = sharp('input.jpg');

const [thumb, medium, large] = await Promise.all([
  pipeline.clone().resize(150, 150).toBuffer(),
  pipeline.clone().resize(400).toBuffer(),
  pipeline.clone().resize(1200).toBuffer(),
]);
```

## Streams & Buffers

```javascript
import fs from 'fs';

// Stream input/output
const readStream = fs.createReadStream('input.jpg');
const writeStream = fs.createWriteStream('output.webp');

readStream
  .pipe(sharp().resize(800).webp())
  .pipe(writeStream);

// Buffer to buffer
const inputBuffer = fs.readFileSync('input.jpg');
const outputBuffer = await sharp(inputBuffer)
  .resize(400)
  .toBuffer();

// With info
const { data, info } = await sharp(inputBuffer)
  .resize(400)
  .toBuffer({ resolveWithObject: true });

console.log(info);
// { format, width, height, channels, size }
```

## Next.js / API Routes

```typescript
// app/api/image/route.ts
import { NextRequest, NextResponse } from 'next/server';
import sharp from 'sharp';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const url = searchParams.get('url');
  const width = parseInt(searchParams.get('w') || '800');
  const quality = parseInt(searchParams.get('q') || '80');

  // Fetch original image
  const response = await fetch(url!);
  const buffer = Buffer.from(await response.arrayBuffer());

  // Process
  const processed = await sharp(buffer)
    .resize(width)
    .webp({ quality })
    .toBuffer();

  return new NextResponse(processed, {
    headers: {
      'Content-Type': 'image/webp',
      'Cache-Control': 'public, max-age=31536000',
    },
  });
}
```

## Generate Thumbnails

```javascript
import sharp from 'sharp';
import path from 'path';

async function generateThumbnails(inputPath, outputDir) {
  const sizes = [
    { name: 'thumb', width: 150, height: 150 },
    { name: 'small', width: 400 },
    { name: 'medium', width: 800 },
    { name: 'large', width: 1200 },
  ];

  const basename = path.basename(inputPath, path.extname(inputPath));
  const pipeline = sharp(inputPath);

  const results = await Promise.all(
    sizes.map(async ({ name, width, height }) => {
      const outputPath = path.join(outputDir, `${basename}-${name}.webp`);

      const info = await pipeline
        .clone()
        .resize(width, height, {
          fit: height ? 'cover' : 'inside',
          withoutEnlargement: true
        })
        .webp({ quality: 80 })
        .toFile(outputPath);

      return { name, path: outputPath, ...info };
    })
  );

  return results;
}
```

## Handle Uploads

```javascript
import formidable from 'formidable';
import sharp from 'sharp';

async function handleUpload(req) {
  const form = formidable();
  const [fields, files] = await form.parse(req);
  const file = files.image[0];

  // Validate and process
  const metadata = await sharp(file.filepath).metadata();

  if (!['jpeg', 'png', 'webp', 'gif'].includes(metadata.format)) {
    throw new Error('Invalid format');
  }

  // Process and save
  const filename = `${Date.now()}-${file.originalFilename}`;
  const processed = await sharp(file.filepath)
    .resize(1200, 1200, { fit: 'inside', withoutEnlargement: true })
    .keepMetadata()
    .webp({ quality: 80 })
    .toFile(`./uploads/${filename}.webp`);

  return {
    url: `/uploads/${filename}.webp`,
    width: processed.width,
    height: processed.height,
    size: processed.size,
  };
}
```

## Batch Processing

```javascript
import sharp from 'sharp';
import { glob } from 'glob';
import path from 'path';

async function batchOptimize(inputGlob, outputDir, options = {}) {
  const files = await glob(inputGlob);
  const { maxWidth = 1920, quality = 80, format = 'webp' } = options;

  const results = await Promise.all(
    files.map(async (file) => {
      const basename = path.basename(file, path.extname(file));
      const output = path.join(outputDir, `${basename}.${format}`);

      try {
        const info = await sharp(file)
          .resize(maxWidth, null, {
            fit: 'inside',
            withoutEnlargement: true
          })
          .toFormat(format, { quality })
          .toFile(output);

        const originalSize = (await sharp(file).metadata()).size;
        const savings = originalSize ?
          Math.round((1 - info.size / originalSize) * 100) : 0;

        return {
          input: file,
          output,
          width: info.width,
          height: info.height,
          size: info.size,
          savings: `${savings}%`,
          status: 'success'
        };
      } catch (error) {
        return { input: file, status: 'error', error: error.message };
      }
    })
  );

  return results;
}

// Usage
const results = await batchOptimize('./photos/*.jpg', './optimized', {
  maxWidth: 1600,
  quality: 75,
  format: 'webp'
});
```

## Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Input file is missing` | File path doesn't exist | Verify file path is correct |
| `unsupported image format` | Unrecognized input format | Check input is valid image |
| `memory allocation failed` | Image too large | Use `limitInputPixels` or streams |
| `sharp: Installation failed` | Native dependency issue | Run `npm rebuild sharp` |
| `Input image exceeds pixel limit` | Exceeds 268M pixels | Set higher `limitInputPixels` |
| `VipsJpeg: Corrupt JPEG data` | Damaged JPEG file | Use `failOn: 'none'` to try anyway |

## Best Practices

1. **Use streams** for large files to reduce memory
2. **Set concurrency** with `sharp.concurrency(1)` for low-memory environments
3. **Pre-compute sizes** when possible (eager thumbnails)
4. **Use WebP or AVIF** for best compression
5. **Cache processed images** - don't reprocess on every request
6. **Handle EXIF rotation** - Sharp auto-rotates by default
7. **Clone pipelines** for multiple outputs from single input
8. **Use `withoutEnlargement`** to prevent upscaling artifacts
9. **Validate uploads** - check format before processing
10. **Keep metadata** when needed with `keepMetadata()`
