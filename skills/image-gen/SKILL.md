---
name: image-gen
description: Generate website images with Gemini 3 Native Image Generation. Covers hero banners, service cards, infographics with legible text, and multi-turn editing. Includes Australian-specific imagery patterns. Use when stock photos don't fit, need text in images, or require consistent style across assets.
license: MIT
metadata:
  last_verified: "2026-01-14"
---

# Image Generation Skill

Generate and edit website images using Gemini Native Image Generation.

## Models

| Model | ID | Best For |
|-------|-----|----------|
| **Gemini 3 Flash** | `gemini-3-flash-image-generation` | Fast iteration, general use |
| **Gemini 3 Pro** | `gemini-3-pro-image-generation` | 4K, complex prompts, text |

## Capabilities

| Feature | Supported |
|---------|-----------|
| Generate from text | ✅ |
| Edit existing images | ✅ |
| Change aspect ratio | ✅ |
| Widen/extend images | ✅ |
| Style transfer | ✅ |
| Change colours | ✅ |
| Add/remove elements | ✅ |
| Text in images | ✅ (legible!) |
| Multiple reference images | ✅ (up to 14) |
| 4K resolution | ✅ (Pro only) |

## Aspect Ratios

```
1:1   | 2:3  | 3:2  | 3:4  | 4:3
4:5   | 5:4  | 9:16 | 16:9 | 21:9
```

## Resolutions (Pro only)

| Size | 1:1 | 16:9 | 4:3 |
|------|-----|------|-----|
| 1K | 1024x1024 | 1376x768 | 1184x880 |
| 2K | 2048x2048 | 2752x1536 | 2368x1760 |
| 4K | 4096x4096 | 5504x3072 | 4736x3520 |

## Quick Start

```typescript
import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// Generate new image
const response = await ai.models.generateContent({
  model: "gemini-3-flash-image-generation",
  contents: "A professional plumber in hi-vis working in modern Australian home",
  config: {
    responseModalities: ["TEXT", "IMAGE"],
    imageGenerationConfig: {
      aspectRatio: "16:9",
    },
  },
});

// Extract image
for (const part of response.candidates[0].content.parts) {
  if (part.inlineData) {
    const buffer = Buffer.from(part.inlineData.data, "base64");
    fs.writeFileSync("hero.png", buffer);
  }
}
```

## Model Selection

| Requirement | Use |
|-------------|-----|
| Fast iteration | Gemini 3 Flash |
| 4K resolution | Gemini 3 Pro |
| Text in images | Pro (better legibility) |
| Simple edits | Gemini 3 Flash |
| Complex compositions | Gemini 3 Pro |
| Infographics/diagrams | Gemini 3 Pro |

## When to Use

**Use Gemini Image Gen when:**
- Stock photos don't fit brand/context
- Need Australian-specific imagery
- Need text in images (infographics, diagrams)
- Need consistent style across multiple images
- Need to edit/modify existing images
- Client has no photos of their work

**Don't use when:**
- Client has good photos of actual work
- Real team photos needed (discuss first)
- Product shots (use real products)
- Legal/compliance concerns

## Reference Files

- `references/prompting.md` - Effective prompt patterns
- `references/website-images.md` - Hero, service, background templates
- `references/editing.md` - Multi-turn editing patterns
- `references/local-imagery.md` - Australian-specific details
- `references/integration.md` - API code examples
