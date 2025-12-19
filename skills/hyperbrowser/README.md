# Hyperbrowser Skill

Build browser automation, web scraping, and AI-driven browser agent applications using Hyperbrowser's cloud platform and HyperAgent framework.

## When to Use This Skill

Use this skill when the user wants to:
- Scrape websites or extract structured data
- Automate browser interactions with AI
- Build web crawlers
- Use cloud browsers with anti-detection
- Create AI agents that browse the web

## Example Repositories (SCAN THESE)

When building Hyperbrowser applications, fetch and scan these repos for current examples:

- **https://github.com/hyperbrowserai/examples** - Standalone examples (scraping, extraction, agents, CLI tools)
- **https://github.com/hyperbrowserai/hyperbrowser-app-examples** - Full Next.js/React applications

## Packages

| Package | Purpose | Install |
|---------|---------|---------|
| `@hyperbrowser/sdk` | Cloud browser sessions, scraping, crawling, extraction, agent APIs | `npm i @hyperbrowser/sdk` |
| `@hyperbrowser/agent` | AI-powered browser automation (HyperAgent) | `npm i @hyperbrowser/agent` |
| `zod` | Schema validation for structured extraction | `npm i zod` |
| `playwright-core` | Browser automation (optional, for CDP) | `npm i playwright-core` |

## Environment Variables

```bash
HYPERBROWSER_API_KEY=your_api_key  # Required for SDK
OPENAI_API_KEY=your_key            # For HyperAgent with OpenAI
ANTHROPIC_API_KEY=your_key         # For HyperAgent with Anthropic
GEMINI_API_KEY=your_key            # For HyperAgent with Gemini
DEEPSEEK_API_KEY=your_key          # For HyperAgent with DeepSeek
```

---

## SDK Patterns (@hyperbrowser/sdk)

### Initialization

```typescript
import { Hyperbrowser } from "@hyperbrowser/sdk";
import { config } from "dotenv";

config();

const hb = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});
```

### Session Management

```typescript
// Create a session
const session = await hb.sessions.create({
  useProxy: true,
  useStealth: true,
  acceptCookies: true,
  adblock: true,
  annoyances: true,
  solveCaptchas: true,
});

console.log("Live URL:", session.liveUrl);  // Watch in browser
console.log("WS Endpoint:", session.wsEndpoint);  // For Playwright/Puppeteer

// Stop session when done
await hb.sessions.stop(session.id);
```

### Session Options Reference

```typescript
{
  useProxy?: boolean,              // Route through proxy
  useStealth?: boolean,            // Anti-detection measures
  useUltraStealth?: boolean,       // Enhanced anti-detection
  acceptCookies?: boolean,         // Auto-accept cookie banners
  adblock?: boolean,               // Block ads
  annoyances?: boolean,            // Block popups/notifications
  solveCaptchas?: boolean,         // Auto-solve CAPTCHAs
  proxyCountry?: string,           // Proxy location (e.g., "US")
  proxyState?: string,             // US state for proxy
  screen?: { width, height },      // Screen resolution
  device?: ["desktop" | "mobile"],
  platform?: ["chrome" | "firefox" | "safari" | "edge"],
  extensionIds?: string[],         // Browser extensions
  browserArgs?: string[],          // Chrome arguments
  timeoutMinutes?: number,         // Session timeout
  region?: "us-central" | "us-east" | "us-west" | "europe-west" | "asia-south",
}
```

### Scraping

```typescript
// Simple scrape
const result = await hb.scrape.startAndWait({
  url: "https://example.com",
  scrapeOptions: {
    formats: ["markdown", "html", "links", "screenshot"],
    onlyMainContent: true,
    waitFor: 3000,  // Wait for JS to render
  },
});

console.log(result.data?.markdown);
console.log(result.data?.links);

// Batch scrape multiple URLs
const batch = await hb.scrape.batch.startAndWait({
  urls: ["https://site1.com", "https://site2.com"],
  scrapeOptions: { formats: ["markdown"] },
});
```

### Crawling

```typescript
const crawl = await hb.crawl.startAndWait({
  url: "https://example.com",
  maxPages: 10,
  followLinks: true,
  includePatterns: ["/blog/*", "/docs/*"],
  excludePatterns: ["/admin/*"],
  scrapeOptions: {
    formats: ["markdown"],
    onlyMainContent: true,
  },
});

for (const page of crawl.data || []) {
  console.log(page.url, page.markdown?.slice(0, 100));
}
```

### Data Extraction with Zod Schemas

```typescript
import { z } from "zod";

const ProductSchema = z.object({
  name: z.string().describe("Product name"),
  price: z.number().describe("Price in USD"),
  rating: z.string().describe("Customer rating"),
  inStock: z.boolean().describe("Whether item is in stock"),
});

const result = await hb.extract.startAndWait({
  urls: ["https://amazon.com/dp/..."],
  prompt: "Extract the product details from this page",
  schema: ProductSchema,
});

const product = result.data as z.infer<typeof ProductSchema>;
console.log(product.name, product.price);
```

### Playwright/Puppeteer Integration

```typescript
import { chromium } from "playwright-core";

const session = await hb.sessions.create();

try {
  const browser = await chromium.connectOverCDP(session.wsEndpoint);
  const context = browser.contexts()[0];
  const page = await context.newPage();

  await page.goto("https://example.com");
  await page.fill("#search", "query");
  await page.click("button[type=submit]");

  const content = await page.content();
} finally {
  await hb.sessions.stop(session.id);
}
```

---

## Agent APIs (via SDK)

The SDK provides multiple AI agent types for different use cases.

### Browser Use Agent (OpenAI-based)

```typescript
const result = await hb.agents.browserUse.startAndWait({
  task: "Go to Amazon, search for 'laptop', and get the top 5 results with prices",
  llm: "gpt-4o",
  useVision: true,
  maxSteps: 20,
  sessionOptions: {
    useProxy: true,
    useStealth: true,
  },
});

console.log(result.data?.finalResult);
```

### Claude Computer Use Agent

```typescript
const result = await hb.agents.claudeComputerUse.startAndWait({
  task: "Navigate to GitHub and star the hyperbrowserai/examples repo",
  llm: "claude-sonnet-4-20250514",
  maxSteps: 15,
  sessionOptions: { useStealth: true },
});
```

### CUA (OpenAI Computer Use Agent)

```typescript
const result = await hb.agents.cua.startAndWait({
  task: "Compare iPhone 16 Pro and Samsung S24 Ultra camera specs",
  maxSteps: 25,
  sessionOptions: {
    useProxy: true,
    useStealth: true,
    acceptCookies: true,
  },
});

console.log(result.data?.finalResult);
```

### Session Reuse Pattern

```typescript
// Create session once, use for multiple agent tasks
const session = await hb.sessions.create({
  useProxy: true,
  useStealth: true,
});

try {
  // First task
  await hb.agents.cua.startAndWait({
    task: "Log into the website",
    sessionId: session.id,
    keepBrowserOpen: true,
  });

  // Second task (same session, logged in)
  const result = await hb.agents.cua.startAndWait({
    task: "Navigate to settings and export data",
    sessionId: session.id,
  });
} finally {
  await hb.sessions.stop(session.id);
}
```

---

## HyperAgent Patterns (@hyperbrowser/agent)

HyperAgent provides a higher-level, more flexible API for AI browser automation.

### Initialization

```typescript
import { HyperAgent } from "@hyperbrowser/agent";

// With OpenAI
const agent = new HyperAgent({
  llm: { provider: "openai", model: "gpt-4o" },
});

// With Anthropic
const agent = new HyperAgent({
  llm: { provider: "anthropic", model: "claude-sonnet-4-20250514" },
});

// With Gemini
const agent = new HyperAgent({
  llm: { provider: "gemini", model: "gemini-2.5-flash" },
});

// With DeepSeek
const agent = new HyperAgent({
  llm: { provider: "deepseek", model: "deepseek-chat" },
});

// Using cloud browsers
const agent = new HyperAgent({
  llm: { provider: "openai", model: "gpt-4o" },
  browserProvider: "Hyperbrowser",  // Uses HYPERBROWSER_API_KEY
});
```

### Execute Full Task

```typescript
const agent = new HyperAgent({
  llm: { provider: "openai", model: "gpt-4o" },
});

const result = await agent.executeTask(
  "Go to Amazon, search for 'mechanical keyboard', and list the top 3 results with prices"
);

console.log(result.output);
await agent.closeAgent();
```

### Page-Level Control

```typescript
const agent = new HyperAgent({
  llm: { provider: "anthropic", model: "claude-sonnet-4-20250514" },
});

const page = await agent.newPage();
await page.goto("https://flights.google.com");

// Multi-step task (visual mode - uses screenshots)
await page.ai("Search for flights from NYC to LA on January 15");

// Single action (a11y mode - faster, uses accessibility tree)
await page.perform("Click the search button");
await page.perform("Select the first flight option");

await agent.closeAgent();
```

### Structured Extraction

```typescript
import { z } from "zod";

const FlightSchema = z.object({
  flights: z.array(z.object({
    airline: z.string(),
    price: z.number(),
    departure: z.string(),
    arrival: z.string(),
    duration: z.string(),
  })),
});

const page = await agent.newPage();
await page.goto("https://flights.google.com");
await page.ai("Search for flights from Miami to Seattle next week");

// Extract with schema validation
const flights = await page.extract("Get the flight options", FlightSchema);
console.log(flights);  // Typed as z.infer<typeof FlightSchema>

await agent.closeAgent();
```

### Output Schema for Tasks

```typescript
const MovieSchema = z.object({
  title: z.string(),
  director: z.string(),
  year: z.number(),
  rating: z.string(),
});

const result = await agent.executeTask(
  "Go to IMDb, search for 'Inception', and get the movie details",
  { outputSchema: MovieSchema }
);

const movie = JSON.parse(result.output);
console.log(movie.title, movie.director);
```

### Custom Actions

```typescript
import { z } from "zod";
import type { AgentActionDefinition, ActionContext, ActionOutput } from "@hyperbrowser/agent";

const SaveToFileAction: AgentActionDefinition = {
  type: "saveToFile",
  actionParams: z.object({
    filename: z.string().describe("Name of the file to save"),
    content: z.string().describe("Content to save"),
  }),
  run: async (ctx: ActionContext, params): Promise<ActionOutput> => {
    const fs = await import("fs/promises");
    await fs.writeFile(params.filename, params.content);
    return {
      success: true,
      message: `Saved to ${params.filename}`,
    };
  },
};

const agent = new HyperAgent({
  llm: { provider: "openai", model: "gpt-4o" },
  customActions: [SaveToFileAction],
});

await agent.executeTask(
  "Go to HackerNews, get top 5 stories, and save them to stories.txt"
);
```

### MCP Server Integration

```typescript
const agent = new HyperAgent({
  llm: { provider: "openai", model: "gpt-4o" },
});

await agent.initializeMCPClient({
  servers: [
    {
      command: "npx",
      args: ["@anthropic/weather-mcp"],
      id: "weather",
    },
  ],
});

// Agent now has access to weather tools
await agent.executeTask(
  "Check the weather in San Francisco and recommend what to wear"
);

await agent.closeAgent();
```

### Action Caching & Replay

```typescript
// Record a workflow
const result = await page.ai("Log into the dashboard and export monthly report");
const cache = result.actionCache;

// Save for later
import fs from "fs";
fs.writeFileSync("workflow-cache.json", JSON.stringify(cache));

// Replay later (deterministic, no LLM calls)
const savedCache = JSON.parse(fs.readFileSync("workflow-cache.json", "utf-8"));
const replayResult = await page.runFromActionCache(savedCache, {
  maxXPathRetries: 3,
});

console.log(replayResult.steps);  // Shows success/failure per step
```

### Async Task Control

```typescript
const task = await page.aiAsync("Long-running multi-step workflow");

// Monitor status
console.log(task.getStatus());  // "running"

// Pause/resume/cancel
task.pause();
console.log(task.getStatus());  // "paused"
task.resume();

// Handle errors
task.emitter.on("error", (err) => console.error(err));

// Wait for completion
while (!["completed", "failed", "cancelled"].includes(task.getStatus())) {
  await new Promise(r => setTimeout(r, 1000));
}
```

---

## Common Patterns

### CLI Tool Pattern

```typescript
import { Hyperbrowser } from "@hyperbrowser/sdk";
import { z } from "zod";
import * as readline from "readline";

const hb = new Hyperbrowser({ apiKey: process.env.HYPERBROWSER_API_KEY });

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

const ask = (q: string) => new Promise<string>(r => rl.question(q, r));

async function main() {
  const query = await ask("Enter search query: ");

  const result = await hb.extract.startAndWait({
    urls: [`https://google.com/search?q=${encodeURIComponent(query)}`],
    prompt: "Extract the top 5 search results",
    schema: z.object({
      results: z.array(z.object({
        title: z.string(),
        url: z.string(),
        snippet: z.string(),
      })),
    }),
  });

  console.log(result.data);
  rl.close();
}

main();
```

### Next.js API Route Pattern

```typescript
// app/api/scrape/route.ts
import { NextRequest, NextResponse } from "next/server";
import { Hyperbrowser } from "@hyperbrowser/sdk";
import { z } from "zod";

const hb = new Hyperbrowser({ apiKey: process.env.HYPERBROWSER_API_KEY });

export async function POST(req: NextRequest) {
  const { url } = await req.json();

  if (!url) {
    return NextResponse.json({ error: "URL required" }, { status: 400 });
  }

  try {
    const result = await hb.scrape.startAndWait({
      url,
      scrapeOptions: { formats: ["markdown"] },
      sessionOptions: { useStealth: true },
    });

    return NextResponse.json({ content: result.data?.markdown });
  } catch (error) {
    return NextResponse.json({ error: "Scrape failed" }, { status: 500 });
  }
}
```

### Scheduled Job Pattern

```typescript
import cron from "node-cron";
import { Hyperbrowser } from "@hyperbrowser/sdk";

const hb = new Hyperbrowser({ apiKey: process.env.HYPERBROWSER_API_KEY });

async function checkPrices() {
  const result = await hb.extract.startAndWait({
    urls: ["https://example.com/product"],
    prompt: "Extract the current price",
    schema: z.object({ price: z.number() }),
  });

  const price = result.data?.price;
  if (price && price < 100) {
    // Send notification
    console.log(`Price dropped to $${price}!`);
  }
}

// Run every hour
cron.schedule("0 * * * *", checkPrices);
```

### Error Handling Pattern

```typescript
import { HyperbrowserError } from "@hyperbrowser/sdk";

try {
  const result = await hb.scrape.startAndWait({ url });
} catch (error) {
  if (error instanceof HyperbrowserError) {
    if (error.statusCode === 401) {
      console.error("Invalid API key");
    } else if (error.statusCode === 429) {
      console.error("Rate limited - try again later");
    } else {
      console.error(`Hyperbrowser error: ${error.message}`);
    }
  } else {
    throw error;
  }
}
```

---

## Quick Reference

### When to Use What

| Use Case | Tool |
|----------|------|
| Simple page scrape | `hb.scrape.startAndWait()` |
| Multi-page crawl | `hb.crawl.startAndWait()` |
| Structured data extraction | `hb.extract.startAndWait()` with Zod schema |
| Complex multi-step automation | `agent.executeTask()` or `page.ai()` |
| Single action (click, fill) | `page.perform()` |
| Full browser control | Playwright/Puppeteer via `session.wsEndpoint` |
| AI agent with tool use | `hb.agents.browserUse` or `hb.agents.cua` |

### Session Options Cheatsheet

```typescript
// Anti-detection
{ useStealth: true, useProxy: true }

// Auto-handle popups
{ acceptCookies: true, adblock: true, annoyances: true }

// Captcha solving
{ solveCaptchas: true }

// Geographic targeting
{ proxyCountry: "US", proxyState: "CA" }

// Mobile emulation
{ device: ["mobile"], screen: { width: 390, height: 844 } }
```

### LLM Provider Quick Setup

```typescript
// OpenAI (most common)
{ llm: { provider: "openai", model: "gpt-4o" } }

// Anthropic Claude
{ llm: { provider: "anthropic", model: "claude-sonnet-4-20250514" } }

// Google Gemini
{ llm: { provider: "gemini", model: "gemini-2.5-flash" } }

// DeepSeek (budget option)
{ llm: { provider: "deepseek", model: "deepseek-chat" } }
```
